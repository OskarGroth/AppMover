# AppMover
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Framework for moving your application bundle to Applications folder on launch.

![OGSwitch for macOS](screen.png "AppMover")

Requirements
------------
Builds and runs on macOS 10.15 or higher. Does NOT support sandboxed applications.


## Installation (Carthage)
Configure your Cartfile to use `AppMover`:

```github "OskarGroth/AppMover" ~> 1.0```

Requires Swift 5.

## Installation (Swift Package Manager)
```
https://github.com/OskarGroth/AppMover
```


Usage
-----

Call ```AppMover.moveIfNecessary()``` at the beginning of ```applicationWillFinishLaunching```.

## Credits

Inspired by [LetsMove](https://github.com/potionfactory/LetsMove/).

## License
The MIT License (MIT)

Copyright (c) 2020 Oskar Groth

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
