# crog

Crog is a simple Crystal library to parse up the Open Graph meta data for web pages.
If you have ever wondered how does sites like Reddit, Facebook etc fetch the relevant images and other 
metadata from 3rd party sites, this is it.

Special thanks to https://metascraper.js.org/
whose rules i referenced throughout my development.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crog:
    github: rishavs/crog
```

## Usage

```crystal
require "crog"
```

To use the library, simple call the Parse method as;
````
mdata = Crog::Parse.new(url)
````
the variable here will hold an object with attributes;
````
            property image :        String | Nil = nil
            property image_width :  Int32 | Nil = nil
            property image_height : Int32 | Nil = nil
            property url :          String | Nil = nil
            property description :  String | Nil = nil
            property title :        String | Nil = nil
            property author :       String | Nil = nil
            property date :         String | Nil = nil
            property logo :         String | Nil = nil
            property tags         = [] of String
````


## Development

A lot of edge cases are not yet picked up. I have left them in the crog.cr file for future reference.

## Contributing

1. Fork it (<https://github.com/your-github-user/crog/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Rishav](https://github.com/rishavs) Rishav Sharan - creator, maintainer
