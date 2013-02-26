PJTernarySearchTree
===================

PJTernarySearchTree is an Objective-C implementation of Ternary Search Tree for Mac OS X and iOS.
It was designed to be a data structure/tool for text autocompletion, however, you may use it as a simple in-memory database because it supports any objects(see the protocol).

For iOS developers, PJTernarySearchTree is a great data source for [HTAutocompleteTextField](https://github.com/hoteltonight/HTAutocompleteTextField "HTAutocompleteTextField").

I'm using PJTernarySearchTree in [Mammoth Web Browser](https://itunes.apple.com/us/app/mammoth-web-browser-premium/id464736531?ls=1&mt=8 "Mammoth Web Browser") for URL autocompletion and history indexing, it can search through 50k+ items within 0.007s. With auto pruning, it runs even faster in realtime typing autocompletion (e.g. "g"->"gi"->"git"...).

# Features:

- Store any objects
- Auto pruning (great for realtime autocompletion)
- Serializing to binary files
- Unicode support
- Count limited retrieving
- Sync or Async

Todos:

- Optimize memory usage
- Better pruning/cache mechanism
- Maybe a disk storage version?

# Managing item/string

~~~
	- (void)insertItem:(id<PJSearchableItem>)item;
	- (void)insertString:(NSString *)str;

	- (void)removeItem:(id<PJSearchableItem>)item;
	- (void)removeString:(NSString *)str;
~~~

# Retrieving

~~~
NSArray * retrieved = nil;

    retrieved = [tree retrievePrefix:@"http://" countLimit:0];  
    NSLog(@"Return all matches: %@",retrieved);
    
    retrieved = [tree retrievePrefix:@"http://" countLimit:2];
    NSLog(@"Return 2 items: %@",retrieved);

    retrieved = [tree retrievePrefix:@"http://www." countLimit:0];
    NSLog(@"Pruning: %@",retrieved);

    [tree retrievePrefix:@"http" countLimit:0 callback:^(NSArray *retrieved) {
        NSLog(@"Callback: %@",retrieved);
    }];
    
    [tree removeString:@"http://www.face.com"];
    retrieved = [tree retrievePrefix:@"http://www.fa" countLimit:0];
    NSLog(@"Remove one: %@",retrieved);
~~~

# Serializing

~~~

	PJTernarySearchTree * tree = [PJTernarySearchTree treeWithFile:savePath];
	
	[tree saveTreeToFile:savePath];

~~~

# License

 This code is distributed under the terms and conditions of the MIT license.

 Copyright (c) 2013 Yichao 'Peak' Ji

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.