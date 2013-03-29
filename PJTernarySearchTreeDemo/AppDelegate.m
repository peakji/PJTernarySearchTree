#import "AppDelegate.h"
#import "PJTernarySearchTree.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSString * savePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.tree"];
    
    
    PJTernarySearchTree * tree = [PJTernarySearchTree treeWithFile:savePath];
    
    if(tree)
    {
        NSLog(@"Loaded from file!");
    }
    else
    {
        NSLog(@"Make a new one, and save it");
        
        tree = [[PJTernarySearchTree alloc] init];
        
        [tree insertString:@"http://www.peakji.com"];
        [tree insertString:@"http://www.peak-labs.com"];
        [tree insertString:@"http://www.facebook.com"];
        [tree insertString:@"http://www.face.com"];
        [tree insertString:@"http://blog.foo.com"];
        [tree insertString:@"http://blog.foo.com/bar"];
        
        [tree insertString:@"http://chinese.hello.com/你好"];     // Supports Unicode languages!
        [tree insertString:@"http://chinese.hello.com/你好吗?"];
        
        [tree saveTreeToFile:savePath];
    }
    
    NSArray * retrieved = nil;
    
    // countLimit = 0 : no limit
    // or use [tree retrievePrefix:@"http://"]
    retrieved = [tree retrievePrefix:@"http://" countLimit:0];
    NSLog(@"Return all matches: %@",retrieved);
    
    
    // Return 2 items
    retrieved = [tree retrievePrefix:@"http://" countLimit:2];
    NSLog(@"Return 2 items: %@",retrieved);

    
    // PJTernarySearchTree will cache the previous query to speed up retrieving (this is great for autocompletion) -- pruning
    retrieved = [tree retrievePrefix:@"http://www." countLimit:0];
    NSLog(@"Cached: %@",retrieved);
    
    
    // Async
    [tree retrievePrefix:@"http" countLimit:0 callback:^(NSArray *retrieved) {
        NSLog(@"Callback: %@",retrieved);
    }];
    
    
    // Remove a string (or object)
    // For non-string items, use [tree removeItem:obj];
    [tree removeString:@"http://www.face.com"];
    
    retrieved = [tree retrievePrefix:@"http://www.fa" countLimit:0];
    NSLog(@"Remove one: %@",retrieved);
    
    
    // Test 2
    
    PJTernarySearchTree * tagSearchTree = [[PJTernarySearchTree alloc] init];
    [tagSearchTree insertString:@"abc"];
    
    // Return nothing
    NSLog(@"%@",[tagSearchTree retrievePrefix:@"abcd"]);
    
    // Nothing will happen...
    [tagSearchTree insertString:@""];
    [tagSearchTree insertString:nil];
    
    // retrieve 'nil' or @"" will get all items
    NSLog(@"%@",[tagSearchTree retrievePrefix:nil]);
    NSLog(@"%@",[tagSearchTree retrievePrefix:@""]);
    
    return YES;
}

@end
