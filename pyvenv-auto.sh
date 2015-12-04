# pyvenv-auto.sh

#/***************************************************************************
# *   Copyright (C) 2015 Daniel Mueller (deso@posteo.net)                   *
# *                                                                         *
# *   This program is free software: you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation, either version 3 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# *   This program is distributed in the hope that it will be useful,       *
# *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# *   GNU General Public License for more details.                          *
# *                                                                         *
# *   You should have received a copy of the GNU General Public License     *
# *   along with this program.  If not, see <http://www.gnu.org/licenses/>. *
# ***************************************************************************/

# File name of a Python virtual environment configuration file. The
# existence of such a file signals a virtual environment to use.
declare -r PYVENV_CFG="pyvenv.cfg"
# Path to a venv activation script, relative to the venv's root.
declare -r PYVENV_ACTIVATE="bin/activate"

function _pyvenv_is_venv()
{
  local path="${1}"
  local cfg="${path}/${PYVENV_CFG}"
  local act="${path}/${PYVENV_ACTIVATE}"
  # A valid environment is constituted by a pyenv.cfg configuration as
  # well as an activate file. We omit sanity checks such as those for
  # readability here. It is impossible to check everything (for
  # instance, the activate script could be corrupted) and we are sort of
  # in a hot path so we do not want to do unnecessary work.
  test -f "${path}/${PYVENV_CFG}" -a -f "${path}/${PYVENV_ACTIVATE}"
}

function _pyvenv_find_venv()
{
  local path=$(readlink --canonicalize-existing "${1}")

  # As long as we are dealing with a valid (existing) directory, we
  # check it for being a Python venv. If it is we are done.
  while [ $? -eq 0 ]; do
    _pyvenv_is_venv "${path}"
    if [ $? -eq 0 ]; then
      builtin echo "${path}"
      break
    fi

    # If we reached the root and have not found a venv then we can stop.
    if [ "${path}" = "/" ]; then
      break
    fi

    path=$(readlink -e "${path}/../")
  done
}

function _pyvenv_activate_deactivate()
{
  local this_pwd="${PWD}"
  # Check whether somewhere in our path there exists a venv.
  local venv=$(_pyvenv_find_venv "${this_pwd}")

  if [ -n "${venv}" ]; then
    # If that is the case we need to differentiate between two cases:
    # the found venv is the same as the one we already activated or it
    # is different. If it is different we deactivate the current one (if
    # any) and activate the found one. If both are equal there is
    # nothing to be done.
    if [ "${venv}" != "${VIRTUAL_ENV}" ]; then
      if [ -n "${VIRTUAL_ENV}" ]; then
        # A deactivate function is provided by any activated venv.
        deactivate
      fi

      source "${venv}/${PYVENV_ACTIVATE}"
    fi
  else
    # If we did not find a valid environment we still might want to
    # deactivate the current one, if any.
    if [ -n "${VIRTUAL_ENV}" ]; then
      deactivate
    fi
  fi
}

# We overwrite the built-in cd. Currently we do not supported an already
# redefined cd.
function cd()
{
  # Try changing into the given directory. If successful, let the pyenv
  # magic begin.
  if builtin cd "$@"; then
    _pyvenv_activate_deactivate
    return 0
  fi
  return $?
}
