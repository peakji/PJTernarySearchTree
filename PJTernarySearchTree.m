//
//  PJTernarySearchTree.m
//  PJAutocomplete
//
//  Created by Yichao 'Peak' Ji on 2013-2-22.

#import "PJTernarySearchTree.h"

#pragma mark - PJTernarySearchTreeNode

@interface PJTernarySearchTreeNode : NSObject <NSCoding>{
@public
    PJTernarySearchTreeNode * descendingChild;
    PJTernarySearchTreeNode * equalChild;
    PJTernarySearchTreeNode * ascendingChild;
}

@property (strong) id item;
@property (readwrite) unichar nodeChar;

@end

@implementation PJTernarySearchTreeNode

#define kItemKey                @"item"
#define kNodeCharKey            @"nodeChar"
#define kDescendingChildKey     @"de"
#define kEqualChildKey          @"eq"
#define kAscendingChildKey      @"as"

#pragma mark - NSCoding Delegate

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    if((self.item!=nil)&&([self.item conformsToProtocol:@protocol(PJSearchableItem)]==YES))
    {
        [aCoder encodeObject:self.item forKey:kItemKey];
    }
    if([NSString stringWithFormat:@"%C",self.nodeChar]!=nil)
    {
        [aCoder encodeObject:[NSString stringWithFormat:@"%C",self.nodeChar] forKey:kNodeCharKey];
    }
    if(descendingChild!=nil)
    {
        [aCoder encodeObject:descendingChild forKey:kDescendingChildKey];
    }
    if(equalChild!=nil)
    {
        [aCoder encodeObject:equalChild forKey:kEqualChildKey];
    }
    if(ascendingChild!=nil)
    {
        [aCoder encodeObject:ascendingChild forKey:kAscendingChildKey];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [self init])
    {
        if([aDecoder decodeObjectForKey:kItemKey]!=nil)
        {
            self.item = [aDecoder decodeObjectForKey:kItemKey];
        }
        if([aDecoder decodeObjectForKey:kNodeCharKey]!=nil)
        {
            self.nodeChar = [[aDecoder decodeObjectForKey:kNodeCharKey] characterAtIndex:0];
        }
        if([aDecoder decodeObjectForKey:kAscendingChildKey]!=nil)
        {
            ascendingChild = [aDecoder decodeObjectForKey:kAscendingChildKey];
        }
        else
        {
            ascendingChild = nil;
        }
        if([aDecoder decodeObjectForKey:kDescendingChildKey]!=nil)
        {
            descendingChild = [aDecoder decodeObjectForKey:kDescendingChildKey];
        }
        else
        {
            descendingChild = nil;
        }
        if([aDecoder decodeObjectForKey:kEqualChildKey]!=nil)
        {
            equalChild = [aDecoder decodeObjectForKey:kEqualChildKey];
        }
        else
        {
            equalChild = nil;
        }
        
    }
    return self;
    
}

@end


#pragma mark - PJSearchableString (NSString add-on)

@interface NSString (PJSearchableString) <PJSearchableItem>

- (NSString *)stringValue;

@end

@implementation NSString (PJSearchableString)

- (NSString *)stringValue{
    return (NSString *)self;
}

@end


#pragma mark - PJTernarySearchTree

@interface PJTernarySearchTree ()

@property (strong) PJTernarySearchTreeNode * rootNode;
@property (strong) NSString * lastPrefix;
@property (strong) PJTernarySearchTreeNode * lastResultNode;

@end


@implementation PJTernarySearchTree

@synthesize rootNode;

- (id)init{
    self = [super init];
    if (self) {
        self.rootNode = nil;
        self.lastPrefix = nil;
        self.lastResultNode = nil;
    }
    return self;
}


#pragma mark - NSCoding Delegate

#define kRootKey    @"root"

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    if(self.rootNode!=nil)
    {
        [aCoder encodeObject:self.rootNode forKey:kRootKey];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [self init])
    {
        if([aDecoder decodeObjectForKey:kRootKey]!=nil)
        {
            self.rootNode = [aDecoder decodeObjectForKey:kRootKey];
        }
        
    }
    return self;
    
}


#pragma mark - Managing

- (void)insertItem:(id<PJSearchableItem>)item{
    
    if(item==nil||([item isKindOfClass:[NSString class]]&&((NSString *)item).length==0))
    {
        return;
    }
    
    NSString * stringValue = [item stringValue];
    
    PJTernarySearchTreeNode * __strong * found = &(self->rootNode),* node = self->rootNode,* parent = nil;
    
    int index = 0;
    
    while (index < [stringValue length]) {
        unichar ch = [stringValue characterAtIndex:index];
        if (!node) {
            * found = [[PJTernarySearchTreeNode alloc] init];
            node = *found;
            node.nodeChar = ch;
        }
        if (ch < node.nodeChar) {
            found = &(node->descendingChild);
            node = node->descendingChild;
        } else if (ch == node.nodeChar) {
            parent = node;
            found = &(node->equalChild);
            node = node->equalChild;
            index++;
        } else {
            found = &(node->ascendingChild);
            node = node->ascendingChild;
        }
    }
    
    if (parent.item == nil) {
        parent.item = item;
    } else {
        if ([parent.item isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)parent.item addObject:item];
        } else {
            parent.item = [NSMutableArray arrayWithObjects:parent.item,item, nil];
        }
    }
}

- (void)insertString:(NSString *)str{
    [self insertItem:str];
}

- (BOOL)isEmptyNode:(PJTernarySearchTreeNode *)node{
    if((node==nil)||(node.item==nil && node->descendingChild==nil && node->equalChild==nil && node->ascendingChild==nil))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)removeItem:(id<PJSearchableItem>)item{
    
    self.lastResultNode = nil;
    self.lastPrefix = nil;
    
    NSMutableArray * route = [self routePrefixRoot:[item stringValue]];
    
    PJTernarySearchTreeNode * node = [route lastObject];
    
    if(node!=nil)
    {
        node.item = nil;
    }
    
    if([self isEmptyNode:node]==YES)
    {
        for(int i = [route count]-1;i>=0;i--)
        {
            PJTernarySearchTreeNode * checkNode = [route objectAtIndex:i];
            
            if(checkNode->ascendingChild!=nil && ([self isEmptyNode:checkNode->ascendingChild]==YES))
            {
                checkNode->ascendingChild = nil;
            }
            else
            {
                break;
            }
            if(checkNode->equalChild!=nil && ([self isEmptyNode:checkNode->equalChild]==YES))
            {
                checkNode->equalChild = nil;
            }
            else
            {
                break;
            }
            if(checkNode->descendingChild!=nil && ([self isEmptyNode:checkNode->descendingChild]==YES))
            {
                checkNode->descendingChild = nil;
            }
            else
            {
                break;
            }
        }
    }
}

- (void)removeString:(NSString *)str{
    [self removeItem:str];
}


#pragma mark - Main

- (NSMutableArray *)routePrefixRoot:(NSString*)prefix{
    
    int index = 0;
    
    NSMutableArray * array = [NSMutableArray array];
    
    PJTernarySearchTreeNode * node = self->rootNode,* found;
    
    while (index < [prefix length]) {
        
        unichar ch = [prefix characterAtIndex:index];
        if (ch < node.nodeChar) {
            if (!node->descendingChild) {
                return nil;
            }
            node = node->descendingChild;
            
            continue;
        } else if (ch == node.nodeChar) {
            found = node;
            [array addObject:found];
            node = node->equalChild;
            index++;
            continue;
        } else {
            if (!node->ascendingChild) {
                return nil;
            }
            node = node->ascendingChild;
            continue;
        }
    }
    return array;
}

- (unichar)lowerCaseChar:(unichar)ch{
    if(ch>='A'&&ch<='Z')
    {
        return ch+'a'-'A';
    }
    return ch;
}

- (BOOL)startWithCap:(NSString *)str{
    unichar first = [str characterAtIndex:0];
    if(first>='A'&&first<='Z')
    {
        return YES;
    }
    return NO;
}

- (short)compareCharA:(unichar)a toCharB:(unichar)b caseSensitive:(BOOL)sensitive{

    if(sensitive==NO)
    {
        a = [self lowerCaseChar:a];
        b = [self lowerCaseChar:b];
    }

    if(a<b){
        return -1;
    }
    else if(a==b)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

- (PJTernarySearchTreeNode *)locatePrefixRoot:(NSString*)prefix withRootNode:(PJTernarySearchTreeNode *)root caseSensitive:(BOOL)sensitive{
    
    int index = 0;
    
    PJTernarySearchTreeNode * node = self->rootNode,* found;
    
    if(root!=nil && (self.lastPrefix!=nil))
    {
        node = root;
        index = [prefix length] - ([prefix length] - [self.lastPrefix length]) - 1;
    }
    
    while (index < [prefix length]) {
        
        if(!node){
            return nil;
        }
        
        unichar ch = [prefix characterAtIndex:index];
        
        short m = [self compareCharA:ch toCharB:node.nodeChar caseSensitive:sensitive];

        if (m<0) {
            if (!node->descendingChild) {
                return nil;
            }
            node = node->descendingChild;
            
            continue;
        } else if (m==0) {
            found = node;
            node = node->equalChild;
            index++;
            continue;
        } else {
            if (!node->ascendingChild) {
                return nil;
            }
            node = node->ascendingChild;
            continue;
        }
    }
    return found;
}

+ (void)addItems:(PJTernarySearchTreeNode*)node toArray:(NSMutableArray*)output limit:(NSUInteger)countLimit{
    if ((countLimit!=0)&&([output count]>=countLimit)) {
        return;
    }
    if (!node.item) {
        return;
    }
    if ([node.item isKindOfClass:[NSArray class]]) {
        [output addObjectsFromArray:node.item];
    } else {
        [output addObject:node.item];
    }
}

- (void)retrieveNodeFrom:(PJTernarySearchTreeNode *)prefixedRoot toArray:(NSMutableArray*)output limit:(NSUInteger)countLimit{
    
    if ((countLimit!=0)&&([output count]>=countLimit)) {
        return;
    }
    if (prefixedRoot == nil) {
        return;
    }
    [self retrieveNodeFrom:prefixedRoot->descendingChild toArray:output limit:countLimit];
    [PJTernarySearchTree addItems:prefixedRoot toArray:output limit:countLimit];
    [self retrieveNodeFrom:prefixedRoot->equalChild toArray:output limit:countLimit];
    [self retrieveNodeFrom:prefixedRoot->ascendingChild toArray:output limit:countLimit];
}

#pragma mark - Retrieving

- (NSArray *)retrieveAll{
    return [self retrieveAllWithCountLimit:0];
}

- (NSArray *)retrieveAllWithCountLimit:(NSUInteger)countLimit{
    NSMutableArray* output = [NSMutableArray array];
    
    [PJTernarySearchTree addItems:self.rootNode toArray:output limit:countLimit];
    
    [self retrieveNodeFrom:self.rootNode->descendingChild toArray:output limit:countLimit];
    [self retrieveNodeFrom:self.rootNode->equalChild toArray:output limit:countLimit];
    [self retrieveNodeFrom:self.rootNode->ascendingChild toArray:output limit:countLimit];
    
    if ((countLimit!=0)&&([output count]>=countLimit)) {
        return [NSArray arrayWithArray:[output objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countLimit)]]];
    }
    else
    {
        return [NSArray arrayWithArray:output];
    }
}

- (NSArray *)retrievePrefix:(NSString *)prefix countLimit:(NSUInteger)countLimit caseSensitive:(BOOL)sensitive{
    
    if(sensitive==NO){
        NSString * oppoString = nil;
        if([self startWithCap:prefix])
        {
            oppoString = [prefix lowercaseString];
        }
        else
        {
            oppoString = [prefix uppercaseString];
        }
        
        NSMutableArray* output = [NSMutableArray array];
        NSLog(@"%@",oppoString);
        [output addObjectsFromArray:[self __retrievePrefix:prefix countLimit:countLimit caseSensitive:NO]];
        [output addObjectsFromArray:[self __retrievePrefix:oppoString countLimit:countLimit caseSensitive:NO]];
        
        if ((countLimit!=0)&&([output count]>=countLimit)) {
            return [NSArray arrayWithArray:[output objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countLimit)]]];
        }
        else
        {
            return [NSArray arrayWithArray:output];
        }
    }
    else
    {
        return [self __retrievePrefix:prefix countLimit:countLimit caseSensitive:YES];
    }
}


- (NSArray *)__retrievePrefix:(NSString *)prefix countLimit:(NSUInteger)countLimit caseSensitive:(BOOL)sensitive{

    if(prefix==nil)
    {
        prefix = @"";
    }
    
    PJTernarySearchTreeNode * prefixedRoot = nil;
    if(prefix.length==0)
    {
        return [self retrieveAllWithCountLimit:countLimit];
    }
    else
    {
        if(self.lastPrefix!=nil && ([prefix hasPrefix:self.lastPrefix]==YES))
        {
            prefixedRoot = [self locatePrefixRoot:prefix withRootNode:self.lastResultNode caseSensitive:sensitive];
        }
        else
        {
            prefixedRoot = [self locatePrefixRoot:prefix withRootNode:nil caseSensitive:sensitive];
        }
    }
    
    if(!prefixedRoot)
    {
        return [NSArray array];
    }
    
    self.lastResultNode = prefixedRoot;
    self.lastPrefix = [NSString stringWithString:prefix];
    
    NSMutableArray* output = [NSMutableArray array];
    [PJTernarySearchTree addItems:prefixedRoot toArray:output limit:countLimit];
    
    [self retrieveNodeFrom:prefixedRoot->equalChild toArray:output limit:countLimit];
    
    if ((countLimit!=0)&&([output count]>=countLimit)) {
        return [NSArray arrayWithArray:[output objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countLimit)]]];
    }
    else
    {
        return [NSArray arrayWithArray:output];
    }
    
}





- (NSArray *)retrievePrefix:(NSString *)prefix countLimit:(NSUInteger)countLimit{
    return [self retrievePrefix:prefix countLimit:countLimit caseSensitive:YES];
}

- (NSArray *)retrievePrefix:(NSString *)prefix caseSensitive:(BOOL)sensitive{
    return [self retrievePrefix:prefix countLimit:0 caseSensitive:sensitive];
}

- (NSArray *)retrievePrefix:(NSString *)prefix{
    
    return [self retrievePrefix:prefix countLimit:0 caseSensitive:YES];
}

- (void)retrievePrefix:(NSString *)prefix callback:(PJTernarySearchResultBlock)callback{
    [self retrievePrefix:prefix countLimit:0 caseSensitive:YES callback:callback];
}

- (void)retrievePrefix:(NSString *)prefix caseSensitive:(BOOL)sensitive callback:(PJTernarySearchResultBlock)callback{
    
    [self retrievePrefix:prefix countLimit:0 caseSensitive:sensitive callback:callback];
}

- (void)retrievePrefix:(NSString *)prefix countLimit:(NSUInteger)countLimit caseSensitive:(BOOL)sensitive callback:(PJTernarySearchResultBlock)callback{
    
    if(!callback)
    {
        return;
    }
    
    dispatch_queue_t ternary_search_queue;
    
    ternary_search_queue = dispatch_queue_create([[NSString stringWithFormat:@"com.PeakJi.PJAutocomplete.ternary_search.%@",prefix] UTF8String], nil);
    
    dispatch_async(ternary_search_queue, ^{
        
        NSArray * array = [self retrievePrefix:prefix countLimit:countLimit caseSensitive:sensitive];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            callback(array);
            
        });
    });
    
}

- (void)retrievePrefix:(NSString *)prefix countLimit:(NSUInteger)countLimit callback:(PJTernarySearchResultBlock)callback{
    
    [self retrievePrefix:prefix countLimit:countLimit caseSensitive:YES callback:callback];
}

#pragma mark - Serializing

- (void)saveTreeToFile:(NSString *)path{
    __autoreleasing NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [data writeToFile:path atomically:YES];
}

+ (PJTernarySearchTree *)treeWithFile:(NSString *)path{
    if (path == nil || [path length] == 0 ||
        [[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
        return nil;
    }
    else
    {
        __autoreleasing PJTernarySearchTree * tree = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return tree;
    }
}

@end
