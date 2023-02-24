# MacPassHTTP

KeePassHTTP plugin for [MacPass](https://github.com/mstarke/MacPass)

## Dependencies

[KeePassHTTPKit](https://github.com/MacPass/KeePassHTTPKit)

[MacPass Source](https://github.com/mstarke/MacPass)

## Installation

### Using a precompiled version

Download the latest release from the [Releases page](https://github.com/MacPass/MacPassHTTP/releases), extract, and copy the resulting file to the MacPass plugin folder at `~/Library/Application Support/MacPass/`. Restart MacPass if you're already running it.

### Building from source

* Clone the repository
```bash
git clone https://github.com/MacPass/MacPassHTTP
cd MacPassHTTP
```
* Install [Carthage](https://github.com/Carthage/Carthage#installing-carthage)
* Fetch and build dependencies for MacPassHTTP
```bash
carthage bootstrap --platform macOS
```
* Clone MacPass and fetch and build dependencies
```bash
cd ..
git clone https://github.com/mstarke/MacPass
cd MacPass
git checkout 0.7.4
git submodule update --init --recursive
carthage bootstrap --platform macOS
```

* If your folder structure isn't like the following, you need to adjust the ````HEADER_SEARCH_PATHS```` to point to the MacPass folder
````
└─ Folder
   ├─ MacPass
   └─ MacPassHTTP
````

* Change back to the MacPassHTTP folder, compile and install
```bash
cd ..
cd MacPassHTTP
xcodebuild
```

The Plugin is moved to the plugin folder of MacPass automacially.
````~/Library/Application Support/MacPass/MacPassHTTP.mpplugin````

## License

The MIT License (MIT)

Copyright (c) 2015-2017 Michael Starke, HicknHack Software GmbH

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Additinal Licenses

### KeePassHTTPKit

The MIT License (MIT)

Copyright (c) 2014 James Hurst<br>
Copyright (c) 2015-2017 Michael Starke, HicknHack Software GmbH

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
