//
//  BPMachOViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/1/14.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPMachOViewController.h"
#import <mach/mach.h>
#include <dlfcn.h>
//#include <mach-o/dyld.h>
#import <mach-o/ldsyms.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#define YY_CORE_SECTION_NAME "__yy_core_config"

#define YY_CORE_CONCAT2(A, B) A ## B

#define YY_CORE_CONCAT(A, B) YY_CORE_CONCAT2(A, B)

#define YY_CORE_SECTION(name) __attribute((used, section("__DATA,"#name" ")))

#define YY_CORE_CONFIG_SECTION YY_CORE_SECTION(__yy_core_config)

#define YY_CORE_UNIQUE_ID(key) YY_CORE_CONCAT(key, YY_CORE_CONCAT(__LINE__, __COUNTER__))


#define YY_CORE_REGISTER(_protocol, _className) \
char * YY_CORE_UNIQUE_ID(_className) YY_CORE_CONFIG_SECTION = (char *)""#_protocol"#"#_className""; \

#ifdef __LP64__
typedef uint64_t yyc_value;
typedef struct section_64 yyc_section;
typedef struct mach_header_64 yyc_mach_header;
#define yyc_getsectbynamefromheader getsectbynamefromheader_64
#else
typedef uint32_t yyc_value;
typedef struct section yyc_section;
typedef struct mach_header yyc_mach_header;
#define yyc_getsectbynamefromheader getsectbynamefromheader
#endif

#define ABC(_param1, _param2) \
char *testData = (char *)""#_param1"#"#_param2"";\

extern const struct mach_header* _NSGetMachExecuteHeader();
typedef void (^YYSectionDataLookupBlock) (const void * _Nullable address);

BOOL checkMethodBeHooked(Class class, SEL selector)
{
    //你也可以借助runtime中的C函数来获取方法的实现地址
    IMP imp = [class instanceMethodForSelector:selector];
    if (imp == NULL)
         return NO;

    //计算出可执行程序的slide值。
    intptr_t pmh = (intptr_t)_NSGetMachExecuteHeader();
    intptr_t slide = 0;
#ifdef __LP64__
    const struct segment_command_64 *psegment = getsegbyname("__TEXT");
#else
    const struct segment_command *psegment = getsegbyname("__TEXT");
#endif
    slide = pmh - psegment->vmaddr;
    NSLog(@"another YYMobile ASLR = %p, executableImageAddress = %p", (void *)slide, (void *)pmh);
    unsigned long startpos = (unsigned long) pmh;
    unsigned long endpos = get_end() + slide;
    unsigned long imppos = (unsigned long)imp;
    NSLog(@"slide:%@, startpos:%@, endpos:%@, imppos:%@", @(slide), @(startpos), @(endpos), @(imppos));
    
    return (imppos < startpos) || (imppos > endpos);
}

YY_CORE_REGISTER(ICrashSDKUtilsCore, YYCrashSDKUtilsCore)
YY_CORE_REGISTER(ICrashSDKUtilsCore1, YYCrashSDKUtilsCore)

int Flower = 1;
int Fruit = 2;
int Vegetables = 3;
#define NameFactory(name) Get##name
#define GetNameInst(name) NameFactory(name)()

#define DeclareGetNameInst(type, name) type GetNameInst(name)
#define DefineGetNameInst(type, name) \
DeclareGetNameInst(type, name) \
{ \
    return name; \
}

//DeclareGetNameInst(int, Flower);
DefineGetNameInst(int, Flower)
DefineGetNameInst(int, Fruit)

@interface BPMachOViewController ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *dictionary;
@end

@implementation BPMachOViewController

- (void)viewDidLoad
{
    int x = GetFruit();
    NSLog(@"x=%@", @(x));
    x = GetFlower();
    NSLog(@"x=%@", @(x));
    [super viewDidLoad];
//    ABC(I, Love);
//    NSLog(@"%s-%s-%s", YYCrashSDKUtilsCore760, YYCrashSDKUtilsCore771, testData);
    _dictionary = @{}.mutableCopy;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self getASLR1];
    [self getASLR2];
    BOOL res = checkMethodBeHooked([self class], @selector(loadData));
    NSLog(@"res:%@", @(res));
    [self loadData];
    ABC(@"I", @"Love");
    NSLog(@"%s", testData);
}

- (void)loadData
{
    [BPMachOViewController readSectionName:YY_CORE_SECTION_NAME imageProcessStep:sizeof(char *) usingBlock:^(const void * _Nullable address) {
        if (NULL == address) {
            return;
        }
        char *strs = *(char **)address;
        NSString *string = [NSString stringWithUTF8String:strs];
        NSArray *tuple = [string componentsSeparatedByString:@"#"];
        if (2 == tuple.count) {
            NSString *protocolName = tuple.firstObject;
            NSString *className = tuple.lastObject;
            self.dictionary[protocolName] = className;
        }
    }];
}

- (void)libVersion
{
    //这里的名称c++其实是指的libc++.dylib这个库。
    uint32_t v1 =  NSVersionOfRunTimeLibrary("c++");
    uint32_t v2 =  NSVersionOfLinkTimeLibrary("c++");
    NSLog(@"v1=%@, v2=%@", @(v1), @(v2));
}

- (void)sectionData
{
    //一般索引为1的都是可执行文件映像
    intptr_t  slide = _dyld_get_image_vmaddr_slide(3);
    unsigned long size = 0;
    char *paddr = getsectdata("__TEXT", "__text", &size);
    char *prealaddr = paddr + slide;  //这才是真实要访问的地址。
//    NSLog(@"prealaddr:%x", prealaddr);
}

+ (void)readSectionName:(const char *)sectionName
       imageProcessStep:(size_t)step
             usingBlock:(YYSectionDataLookupBlock)usingBlock
{
    uint32_t imageCount = _dyld_image_count();
    for (uint32_t imageIndex = 0; imageIndex < imageCount; imageIndex++) {
        const struct mach_header *machHeader = _dyld_get_image_header(imageIndex);
        Dl_info info;
        if (0 == dladdr(machHeader, &info)) { continue; }
        
        [self readSectionName:sectionName
                    imageInfo:info
             imageProcessStep:step
                   usingBlock:usingBlock];
    }
}

+ (void)readSectionName:(const char *)sectionName
              imageInfo:(Dl_info)info imageProcessStep:(size_t)step
             usingBlock:(YYSectionDataLookupBlock)usingBlock
{
//    void *fbase = info.dli_fbase;
//    const yyc_section *section = yyc_getsectbynamefromheader(fbase, "__DATA", sectionName);
//    if (NULL == section) { return ; }
//    for (yyc_value offset = section->offset; offset < section->offset + section->size; offset += step) {
//        !usingBlock ?: usingBlock(fbase + offset);
//    }
#ifndef __LP64__
    // const struct mach_header *mhp = _dyld_get_image_header(0); // both works as below line
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    // 找到之前存储的数据段(Module找BeehiveMods段 和 Service找BeehiveServices段)的一片内存
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", "__yy_core_config", & size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, "__DATA", "__yy_core_config", & size);
#endif /* defined(__LP64__) */
    // 把特殊段里面的数据都转换成字符串存入数组中
    for(int idx = 0; idx < size/sizeof(void*); ++idx){
        char *string = (char*)memory[idx];

        NSString *str = [NSString stringWithUTF8String:string];
        if(!str)continue;
        usingBlock(memory + idx);
    }
}

- (void)getASLR1
{
    intptr_t ASLR = 0;
    void *executableImageAddress = NULL;
    char path[1024];
    unsigned size = sizeof(path) / sizeof(char);;
    int status = _NSGetExecutablePath(path, &size);
    if (0 != status) {
        return;
    }
    uint32_t imageCount = _dyld_image_count();
    if (imageCount > 0) {
        uint32_t index = 0;
        while (index < imageCount) {
            const char *name = _dyld_get_image_name(index);
            if (!strcmp(name, path)) {
                break;
            }
            index++;
            if (index >= imageCount) {
                return;
            }
        }
        ASLR = _dyld_get_image_vmaddr_slide(index);
        executableImageAddress = (void *)_dyld_get_image_header(index);
    }
    
    NSLog(@"YYMobile ASLR = %p, executableImageAddress = %p", (void *)ASLR, executableImageAddress);
}

- (void)getASLR2
{
    //计算出可执行程序的slide值。
    intptr_t realBase = (intptr_t)_NSGetMachExecuteHeader(); // 真实基地址
    intptr_t slide = 0;
#ifdef __LP64__
    const struct segment_command_64 *psegment = getsegbyname("__TEXT");
#else
    const struct segment_command *psegment = getsegbyname("__TEXT");
#endif
    // 构建时指定的基地址
    slide = realBase - psegment->vmaddr;
    
    NSLog(@"another YYMobile ASLR = %p, executableImageAddress = %p, buileBase:%p", (void *)slide, (void *)realBase, (void *)psegment->vmaddr);
}
@end
