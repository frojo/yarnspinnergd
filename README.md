# yarnspinnergd

**WARNING: yarnspinnergd is still super barebones and in early development. It lacks _almost all__ of the standard features of Unity Yarn Spinner and is very untested. [See below](todo) for more details.**

yarnspinnergd is a tool for helping to make games with interactive dialogue in [Godot](https://godotengine.org/). It's port of [Yarn Spinner](https://github.com/thesecretlab/YarnSpinner). It serves the same purpose as Unity YarnSpinner (and adhere's pretty closely to its design), but is written entirely in GDScript instead of C#.

## Missing features

yarnspinnergd is in very early development and is missing many important and core features of Yarn Spinner. This is what yarnspinnergd currently _does_ support:
* importing .yarn.txt files
* running pure text lines (i.e. any commands, conditionals, even node links are **not supported**)

That's it. To drive the point home, here's some important features that yarnspinnergd _does not_ support:
* proper error handling
* importing from a json file
* tags
* any sort of yarn syntax that's not pure text (including node links)
* debugging support
* localization support

## Usage

todo: quickstart guide

todo: example project

Join the [narrative game development](http://lab.to/narrativegamedev) Slack to ask questions of other experienced YarnSpinner users.

### Documentation

The best documentation can be found in [Yarn Spinner for Unity documentation](https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Dialogue/General-Usage.md). Some if it specific for the Unity implementation, but much of it applies to Yarn in general. Also, the design of this port is similar enought that that documentation should be pretty helpful.

A few key differences to watch out for:
* todo: naming convention is different run_line vs RunLine
* todo: coroutines are different in GDScript
* todo: a ton of missing features in this port
* todo: other gotchas

## How to contribute

There are many ways to contribute! Including:
* Using the tool and [reporting any issues](todo) you run into
* Making things with the tool (let me know and I'll reshare!)
* todo: other ways (or maybe delete this section for now)

### Contributing code/documentation

We are very open to pull requests!

In addition to the aforementioned [important missing features](TODO), there are many other ways to help
* documentation (currently there is _none_)

## thankses
I referenced a few other OSS tools for making this readme including:
* [@galaxykate's OSSTA zine](https://github.com/galaxykate/OSSTA-Zine/blob/master/osta-zine.md) for guidance :pray:
* the [contributor's covenant](https://www.contributor-covenant.org/)
* Yarn Spinner's [readme](https://github.com/thesecretlab/YarnSpinner)
* Godot's [contributor's guide](https://docs.godotengine.org/en/3.1/community/contributing/ways_to_contribute.html)
