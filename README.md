# Sanitazer

         ___  __ _ _ __ (_) |_ __ _ _______ _ __
        / __|/ _` | '_ \| | __/ _` |_  / _ \ '__|
        \__ \ (_| | | | | | || (_| |/ /  __/ |
        |___/\__,_|_| |_|_|\__\__,_/___\___|_|



    Clean filenames and title capitalize names in folders and files,
                removing non-ASCII characters


## Requirements

* utf8
* Text::Unidecode
* Date::Simple
* File::Basename
* Cwd

## Running sanitazer
To run sanitazer securely, two bash scripts has been provided:

  * **sanitazerdi** folder_name
     
    Will run sanitazer recursively all folders in **folder_name**

  * **sanitazerfi** folder_name

    Will sanitazer recursively all files in **folder_name**

##  License
Sanitazer includes the following code that has been modified and hopefully improved:

  * **Titlecase** Original version by John Gruber and Re-written and much
    improved by Aristotle Pagaltzis. MIT Lincense

  * **Sanitaze** Originaly from git sanity and modified by Andreas Gohr.                                                     
    GNU  General Public License 2 or later

Otherwise  This program is free software: you can redistribute it and/or modify it under the terms
    of the GNU General Public License as published by the Free Software Foundation, either
    version 3 of the License, or (at your option) any later version.
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU General Public License for more details.
    You should have received a copy of the GNU General Public License along with this program.
    If not, see <https://www.gnu.org/licenses/>.

Copyright (C) 2025 Agustin Navarro (agustin.navarro@gmail.com) 

# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

sanitizer can quickly corrupt the system. Ensure it is run in a directory where file names can be modified.
  






