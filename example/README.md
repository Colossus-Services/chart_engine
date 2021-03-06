# chart_engine (Web Example)

A simple Web Example with `chart_engine`.


## Live Example

You can see [here a live example][live_example]

[live_example]: https://colossus-services.github.io/chart_engine/example/www/

## Running Example from Sources

Git clone the `chart_engine` project (if you don't have it yet).

```shell script
$> git clone https://github.com/Colossus-Services/chart_engine.git
```

Go to `chart_engine` directory:

```shell script
$> cd ./chart_engine
```

Run Dart `pub get` to get the dependencies:  

```shell script
$> dart pub get  
```

Ensure that `webdev` is activated:

```shell script
$> dart pub global activate webdev
```

Run `webdev serve` at `example` to build the project and run the Web server at port `8080`:

```shell script
$> dart pub global run webdev serve example 
```

Open http://127.0.0.1:8080 in your browser.

Have fun!

## GitHub Project

Please visit [chart_engine@GitHub][github] for more.

[github]: https://github.com/Colossus-Services/chart_engine

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

[Apache License - Version 2.0][apache_license]

[apache_license]: https://www.apache.org/licenses/LICENSE-2.0.txt
