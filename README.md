pyvenv-auto
===========


Purpose
-------

**pyvenv-auto** is a simple script that can be used to automatically
detect and activate a Python virtual environment (*venv*) as proposed in
PEP 405 in shell environments.

The program works by overwriting the ``cd`` built-in and enhancing it
with a quick check whether the directory being changed into is part of a
virtual environment and activating or deacting it accordingly.


Usage
-----

After installation as described below, the script itself is activated
whenever a new shell is started. From a user perspective everything
happens without any additional work: whenever a ``cd`` is performed a
check whether the destination describes a virtual environment is
performed. If a valid *venv* structure is found, the virtual environment
will be activated by sourcing the respective ``activate`` file
(``<venv>/bin/activate``). If a *venv* was already active and we left
it, the former environment will be deactivated.

### Deactivation
If, say, for the purpose of testing, **pyvenv-auto** needs to be
disabled, this can happen on a per-shell basis by resetting ``cd`` to
reference the built-in of the same name rather than the function
provided by the program. This binding can be reverted by using:

``$ unset cd``

### Virtual Environments
In Python, virtual environments can be created using the following
command:

``$ python -m venv <directory>``

The ``pyvenv`` script serves the same purpose but got deprecated in
Python 3.6:

``$ pyvenv <directory>``


Installation
------------

The installation of **pyvenv-auto** is as simple as copying the
``pyvenv-auto.sh`` into an arbitrary location on the file system. In
order to activate it it needs to be sourced. This sourcing would
typically happen in some shell initialization file. A common candidate
is ``~/.bashrc``.

In addition to sourcing it, the ``_pyvenv_activate_deactivate`` function
may be invoked afterwards if there is a chance that the current working
directory already contains a virtual environment that should be
activated. If the function were not invoked, a ``cd .`` from the newly
started shell accomplishes the same thing.

In summary, the following lines should be added to your ``~/.bashrc``
file:

```
source <path-to-pyvent-auto>/pyvenv-auto.sh
_pyvenv_activate_deactivate
```


Shell Prompt
------------

Note that this section is not specific to **pyvenv-auto** in any way. It
merely summarizes a problem occuring in the default configuration when
activating a Python *venv* and proposes a solution for it.

By default, Python virtual environments change the command line prompt
(represented by the ``PS1`` environment variable in typical shell
environments) when activated to reflect the currently active venv (if
any). However, the are cases where other facilities also overwrite the
prompt, resulting in a clash.

For example, consider the an environment where ``git-prompt.sh`` is
used to indicate the status of the currently "active" ``git``
repository's status in the prompt.

In order to solve this problem the *venv* specific prompt change should
be deactivated. This deactivation can happen by setting the
``VIRTUAL_ENV_DISABLE_PROMPT`` environment variable to a non-empty
string. Furthermore, the ``PROMPT_COMMAND`` variable which is executed
by the shell (bash in this case; other shells may or may not have a
similar mechanism) before displaying of the prompt should point to a
function capable of creating a prompt combining the otherwise clashing
prompt strings.

For ``git`` and a virtual environment (which could be activated by
**pyvenv-auto**), such a function could look as follows:
```bash
function _prompt()
{
  local venv_ps1=""
  # Check if there is a Python venv active.
  if [ -n "${VIRTUAL_ENV}" ]; then
    # If so, then include its name in the prompt.
    venv_ps1="[$(basename ${VIRTUAL_ENV})] "
  fi

  __git_ps1 "${GREEN}\u@\h${BLUE} ${venv_ps1}\w" " \$${BLACK} " " (%s${BLUE})"
}

PROMPT_COMMAND="_prompt"
```
