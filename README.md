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
