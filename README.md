# yarnspinnergd

**WARNING: yarnspinnergd is still super barebones and in early development. It lacks _almost all_ of the standard features of Unity Yarn Spinner and is very untested. [See below](#missing-features) for more details.**

yarnspinnergd is a tool for helping to make games with interactive dialogue in [Godot](https://godotengine.org/). It's port of [Yarn Spinner](https://github.com/thesecretlab/YarnSpinner). It serves the same purpose as Unity YarnSpinner (and adhere's pretty closely to its design), but is written entirely in GDScript instead of C#.

## Missing features

yarnspinnergd is in very early development and is ***missing many important and core features of Yarn Spinner***. This is what yarnspinnergd currently _does_ support:
* importing .yarn.txt files
* running pure text lines (i.e. any commands, conditionals, even node links are **not supported**)

That's basically _it_. To drive the point home, here's some important features that yarnspinnergd _does not_ support:
* proper error handling
* importing from a json file
* tags
* any sort of yarn syntax that's not pure text (including node links)
* debugging support
* localization support

## Usage

### Getting started

> NOTE: Before using yarnspinnergd, it's recommended to learn how to write a [Yarn file](https://github.com/infiniteammoinc/Yarn) and a little about [Godot](https://docs.godotengine.org/en/3.1/getting_started/step_by_step/your_first_game.html) first.

Clone the repo into your Godot project (note: if you're using git already, beware of [nested repos](https://stackoverflow.com/questions/1871282/nested-git-repositories)).

In your Godot project:
1. Import your `.yarn.txt` file so that it shows up in the `res://` directory. **Note: Must be a `.yarn.txt` file (we don't currently support JSON or other filetypes**
1. Create a Node and attach the `dialogue_runner.gd` script to it
1. Set the exported `Source Text` script variable of the `dialogue_runner.gd` script to the path to your `.yarn.txt` file
1. Write a script that extends 'DialogueUIBehavior`. This will be the main controller for how the dialogue will affect the scene. The important function to write is `run_line()`. See [Unity Yarn Spinner's documentation](https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Unity/YarnSpinner-with-Unity-StepByStep.md) for more info
1. Create a Node and attach your custom Dialogue UI script.
1. In another script, assign your new dialogue UI script as the `dialogue_ui` member of `DialogueRunner`. A simple example:

```
# main.gd

func _ready():
   $dialogue.dialogue_ui = $dialogue_ui

```
   
Feel free to experiment with different setups that work for you! If you're familiar with Unity, it might be helpful to get started with Yarn Spinner in Unity first.


### Help

There aren't any official community channels for yarnspinnergd yet, but there are some other options to talk to real humans and get help:

* Join the [narrative game development](http://lab.to/narrativegamedev) Slack to ask questions of other experienced YarnSpinner users.
* Join the [Godot Discord/IRC/other channels](https://docs.godotengine.org/en/3.1/community/channels.html) for Godot questions
* Report a yarnspinnergd-specific [issue](https://github.com/frojo/yarnspinnergd/issues)

### Documentation

The best documentation can be found in [Yarn Spinner for Unity documentation](https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Dialogue/General-Usage.md). Some of it is specific to the Unity implementation, but much of it applies to Yarn Spinner in general and is helpful for using yarnspinnergd. Also, the design of this port is similar enough that that documentation should be pretty helpful.

_However_, there are few key differences to watch out for:
* C# and GDScript differ in syntax, conventions and philosophies
  * Naming conventions differ. For example, `RunLine()` in C# becomes `run_line()` in GDScript
  * GDScript is not statically typed by default. yarnspinnergd tries to leverage GDScript's [optional static typing](https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/static_typing.html) where it can, but that part of Godot is still pretty buggy.
  * [Coroutines work differently in Godot](https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#coroutines-with-yield)
* As mentioned, this port is [missing many features](#missing-features)

## How to contribute

If you want to contribute, woo! Yay! Please help! Here are a few ideas how:
* Using the tool and [reporting any issues](https://github.com/frojo/yarnspinnergd/issues) you run into
* Making things with the tool (let @frojo know if you make something and he'll retweet/share!)
* Contributing code/documentation/tutorials

### Contributing code/documentation

We are very open to pull requests! Especially because @frojo isn't sure how much time he'll have to work on this himself!

Things that are desperately needed:
* Implementing one of the [important missing features](#missing-features)
* A quickstart guide to help users get started (with possibly an simple example starter project)
  * See [Unity Yarn Spinner's quickstart guide](https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Unity/YarnSpinner-with-Unity-QuickStart.md)
* Documentation. The Unity Yarn Spinner docs are pretty useful, but would be helpful to have more detailed docs on this tool specifically

## Roadmap/Plans

This tool is currently being developed on a best-effort basis. There are no planned timelines for adding new features etc. As of July 2019, @frojo _thinks_ he will be developing this more through the end of the 2019, but other priorities may come up.


## thankses
A few OSS tools/docs were referenced for making this readme including:
* [@galaxykate's OSSTA zine](https://github.com/galaxykate/OSSTA-Zine/blob/master/osta-zine.md) for guidance :pray:
* the [contributor's covenant](https://www.contributor-covenant.org/)
* Yarn Spinner's [readme](https://github.com/thesecretlab/YarnSpinner)
* Godot's [contributor's guide](https://docs.godotengine.org/en/3.1/community/contributing/ways_to_contribute.html)
