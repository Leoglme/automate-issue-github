<h2 align="center">Automate issue github</h2>

<p>shell script to automate git features and gthub issues</p>


![Language](https://img.shields.io/badge/language-shell-6fa323.svg?style=flat)
![Language](https://img.shields.io/badge/language-bash-6fa323.svg?style=flat)


> The source code is on the repo [automate-issue-github](https://github.com/Leoglme/automate-issue-github)

## Install

   ```sh
    $ git clone https://github.com/Leoglme/automate-issue-github
    $ cd automate-issue-github
    $ sh izigit.sh -h
   ```

## Features

```sh
$ create [ticket_number] Create, fetch and checkout branch for ticket ( example: izigit create 654 )
$ reset Reset test branch, so that it is strictly identical to the preprod branch ( example: izigit reset )reset Reset test branch, so that it is strictly identical to the preprod branch ( example: izigit reset )
$ test [ticket_number] Merge issue branch into test branch ( example: izigit test 654 )
$ test [ticket_number] Merge issue branch into test branch ( example: izigit test 654 )
$ pr [ticket_number] Creating a pull request from the github issue branch to the preprod branch ( example: izigit pr 654 )pr [ticket_number] Creating a pull request from the github issue branch to the preprod branch ( example: izigit pr 654 )
$ -h print help
```

## License

Copyright (MIT) 2022 [Dibodev](https://dibodev.com/)
