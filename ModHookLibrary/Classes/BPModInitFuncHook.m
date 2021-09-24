//
//  BPModInitFuncHook.m
//  BPModInitFuncHook
//
//  Created by ptyuan on 2020/4/1.
//
// Ref https://developer.apple.com/documentation/xcode/improving_your_app_s_performance/reducing_your_app_s_launch_time

#import "BPModInitFuncHook.h"
#import <dlfcn.h>
#import <mach-o/getsect.h>

//extern double yy_currentTimes(void);

#ifdef __LP64__
typedef struct mach_header_64 bp_mach_header;
typedef uint64_t bp_pointer;
#else
typedef struct mach_header bp_mach_header;
typedef uint32_t bp_pointer;
#endif

const size_t kInitializerSize = 2000;

static NSMutableArray <NSDictionary *> *_info;

static bp_pointer *Initializer;

static int CurrentPointerIndex;

static bp_pointer ASLR;

static double kSum;

static NSString *const kBPModInitFuncHookOpenKey = @"BPModInitFuncHookOpenKey";
 
struct ProgramVarsStr {
    const void *mh;
    int *NXArgcPtr;
    const char ***NXArgvPtr;
    const char ***environPtr;
    const char **__prognamePtr;
};

typedef void (*InitializerType)(int argc, const char *argv[], const char *envp[], const char *apple[], const struct ProgramVarsStr *vars);

void HookInitFuncInitializer(int argc, const char *argv[], const char *envp[], const char *apple[], const struct ProgramVarsStr *vars) {
    ++CurrentPointerIndex;
    InitializerType f = (InitializerType)Initializer[CurrentPointerIndex];
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    f(argc, argv, envp, apple, vars);
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    
//    double cost = end - start;
//    double dur = cost * 1e6;
//    double msCoust = dur / 1000;
    NSString *funcName = [NSString stringWithFormat:@"%p", f];
    
    Dl_info info;
    if (0 != dladdr(f, &info)) {
        NSString *sname = @(info.dli_sname);
        if (sname.length > 0) {
            funcName = sname;
        }
    }
    
    double cost = end - start;
    double dur = cost * 1e6;
    double msCoust = dur / 1000;
    
    kSum += msCoust;
    
    NSString *args = [NSString stringWithFormat:@"ASLR: %llx, adress: %p", (unsigned long long)ASLR, f] ?: @"";
    [_info addObject:@{
        @"name": funcName,
        @"ts": @(start * 1e6),
        @"dur": @(dur),
        @"tid": @"MainThread",
        @"ph": @"X",
        @"pid": @"pid",
        @"args": @{@"info": args}
    }];
}

static void HookModInitFunc() {
    Dl_info info;
    dladdr(HookModInitFunc, &info);
    bp_mach_header *machHeader = info.dli_fbase;
    unsigned long size = 0;
    bp_pointer *pointer = (bp_pointer *)getsectiondata(machHeader, "__DATA", "__mod_init_func", &size);
    int count = (int)(size / sizeof(void *));
    for (int i = 0; i < count; ++i) {
        bp_pointer ptr = pointer[i];
        Initializer[i] = ptr;
        pointer[i] = (bp_pointer)HookInitFuncInitializer;
    }
    ASLR = (bp_pointer)machHeader;
}

static BOOL IsHookInit;

@interface BPModInitFuncHook()

@property (nonatomic, strong, class) NSMutableArray <NSDictionary *> *info;

@end

@implementation BPModInitFuncHook

+ (void)load {
    IsHookInit = [self open];
    if (!IsHookInit) {
        return ;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSum = 0;
        _info = @[].mutableCopy;
        ASLR = 0;
        CurrentPointerIndex = -1;
        Initializer = calloc(kInitializerSize, sizeof(bp_pointer));
        HookModInitFunc();
    });
}

+ (double)total {
    return kSum;
}

+ (void)clearDatas {
    if (IsHookInit && Initializer) {
        free(Initializer);
    }
}

+ (NSArray<NSDictionary *> *)methodCost {
    return self.info.copy;
}

+ (void)setInfo:(NSMutableArray<NSDictionary *> *)info {
    _info = info;
}

+ (NSMutableArray<NSDictionary *> *)info {
    return _info;
}

+ (BOOL)open {
    return YES;
//    return [[NSUserDefaults standardUserDefaults] boolForKey:kBPModInitFuncHookOpenKey];
}

+ (void)setOpen:(BOOL)open {
    __auto_type ud = NSUserDefaults.standardUserDefaults;
    [ud setBool:open forKey:kBPModInitFuncHookOpenKey];
    [ud synchronize];
}

@end

