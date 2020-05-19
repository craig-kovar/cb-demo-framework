# Using the Couchbase Demo framework

The Couchbase Demo Framework is designed to operate in two modules

* Interactive
* recording

## Interactive

In the interactive mode you are able to execute different modules, follow the on-screen prompts and generally play around with steps.

## Recording mode

The recording mode is very similar to the interactive mode, in that you are able to execute different modules, run series of steps and build up demos.  However,  while in recording mode,  every module you execute and every value you supply will be recorded in a demo file that allows you replay the demo on-demand.

## Toggling modes

It is very easy to toggle between modes using the Couchbase Demo Framework, simple hit the **'w'** key.  To change the demo file to record to simply hit the **'c'** key.

At the top of the framework you will see the following

![empty write mode](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-mode.png)

### First time enabling recording mode

The first time you enable _recording_ mode,  it will prompt you to specify a file to record.  After you enter the name of the file it will then prompt you to provide a brief description.  This description will be displayed as part of the UI.

![new recording](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-newrecording.png)

After you follow the onscreen prompts you will then see the mode set to **recording** and the file being written to displayed as well.

![recording](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-recording.png)

**NOTE - If you select an existing demo file, you will be prompted whether to override the file or append to the file**


## Templating, Setting, and Viewing variables

The Couchbase Demo Framework supports templating within modules. Depending on the command being executed per step a _variable_ may be assigned.  The value of this variable can then be accessed in subsequent steps by enclosing the variable in {{}}.  An example of this may look like the following within a module or recorded demo file

```
PROMPT~Enter username~USER~Administrator
MESSAGE~You entered the username of {{USER}}
```

In this example,  we prompt the user for a username.  We store the entered value into a variable **USER** (Administrator is a default value here) and then display that value in a message back to the user.

For further reference on the supported commands and syntax of a module file please refer to [module language overview](./docs/module_language.md)

### Manually setting a variable

Within the module language there are a number of ways a variable can be set, such as PROMPT, CODE, or others.  However,  sometimes you want to directly set a variable as well.  This can be done by selecting **'s'**

This will prompt you for the variable name and value

### Viewing the known variables

You can alternatively view the list of known variables by selecting **'v'**.  This will list all known variables and values

![variables](https://github.com/craig-kovar/cb-demo-framework/blob/master/docs/cb-demo-framework-variables.png)
