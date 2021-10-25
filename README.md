# seed-vhdl
A seed project to fork to bootstrap a VHDL project with all the code I deemed usefull for any purpose.

> This project is originally made by David SPORN. It is marked
> with CC0 1.0 Universal. To view a copy of this license, visit 
> http://creativecommons.org/publicdomain/zero/1.0
>
> The original source project of this document may be found at 
> https://github.com/sporniket/seed-vhdl

## HOW TO use with ISE 14.7

* Clone this repository using the name of your project, e.g. `super-project`, in the folder that suit you, e.g. `/path/to/projects`
* Change the `origin` remote repository to a brand new remote repository –or remove this remote–.
* With ISE, create a new Project using the following value
  * **Name** : the name of the cloned repository, e.g. `super-project`
  * **Location** : the path to the cloned repository, e.g. `/path/to/projects/super-project`
  * **Working Directory** : it **MUST** be a subdirectory named `workspace`, e.g. `/path/to/projects/super-project/workspace`
* Import all the `*.vhd` files under the library `sporniket`
* Save your project

**There will be no mean to get update from the seed project !** ISE copies any added file into the project location anyway, so I could not find a way to use submodules, for instances.
