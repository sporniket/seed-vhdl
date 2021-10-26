# seed-vhdl
A seed project to fork to bootstrap a VHDL project with all the code I deemed usefull for any purpose.

> This project is originally made by David SPORN. It is marked
> with CC0 1.0 Universal. To view a copy of this license, visit
> http://creativecommons.org/publicdomain/zero/1.0
>
> The original source project of this document may be found at
> https://github.com/sporniket/seed-vhdl

## HOW TO use with ISE 14.7

_Exemples are given in a Unix/Linux like OS. The reader is supposed at ease with using a command shell. Alternative like using a graphical user interface for git and basic drive operations are not described._

_When giving examples of file pathes, projects will be stored inside at an hypothetical location `/path/to/projects`_

### As a standalone project, to contribute.

* In github, fork this project. The forked project will be one of your repositories, e.g. `https://github.com/super-contributor/seed-vhdl`.
* In the project folder, clone your repository : `git clone https://github.com/super-contributor/seed-vhdl`
* Note the path to the cloned repository, e.g. `/path/to/projects/seed-vhdl`.
* With ISE, create a new Project using the following value
  * **Name** : the name of your project, e.g. `seed-vhdl`
  * **Location** : the path of the project, e.g. `/path/to/projects/seed-vhdl`
  * **Working Directory** : it **MUST** be a subdirectory named `workspace`, e.g. `/path/to/projects/seed-vhdl/workspace`
* In the menu _Project_, add a new library named `sporniket`, with the path being the location of the project itself, e.g. `/path/to/projects/seed-vhdl` ; change the setting of all the files with a name starting with `tb_`, that MUST be associated to the _Simulation_ only.
* Save your project.
* Modify the project as you see fit, stage your changes, commit them and push them
* On github, create a pull request to suggest your change, with proper description. The author may or may not accept it, and in any case thank you !

### As a library stored outside a project

* In the project folder, clone this repository : `git clone https://github.com/sporniket/seed-vhdl`
* Note the path to the cloned repository, e.g. `/path/to/projects/seed-vhdl`.
* With ISE, create a new Project using the following value
  * **Name** : the name of your project, e.g. `super-project`
  * **Location** : the path of the project, e.g. `/path/to/projects/super-project`
  * **Working Directory** : it **MUST** be a subdirectory named `workspace`, e.g. `/path/to/projects/super-project/workspace`
* In the menu _Project_, add a new library named `sporniket`, with the path being the location of the cloned repository, e.g. `/path/to/projects/seed-vhdl` ; change the setting of all the files with a name starting with `tb_`, that MUST be associated to the _Simulation_ only.
* Save your project.
* You may put your project under the control of git or other version control software.


### As a git submodule

* Init a local folder with git, e.g. `git init /path/to/projects/super-project`.
* Set the command shell to this folder, e.g. `cd /path/to/projects/super-project`
* With ISE, create a new Project using the following value
  * **Name** : the name of your project, e.g. `super-project`
  * **Location** : the path of the project, e.g. `/path/to/projects/super-project`
  * **Working Directory** : it **MUST** be a subdirectory named `workspace`, e.g. `/path/to/projects/super-project/workspace`
* Ajouter le dépôt `seed-vhdl` en le renommant `sporniket`, e.g. `git submodule add https://github.com/sporniket/seed-vhdl sporniket`
* With ISE, in the menu _Project_, add a new library named `sporniket`, with the path of the submodule, e.g. `/path/to/projects/super-project/sporniket` ; change the setting of all the files with a name starting with `tb_`, that MUST be associated to the _Simulation_ only.
* Save your project.
* Stage the project changes, and commit.
