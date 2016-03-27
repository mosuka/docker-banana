#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# If this scripted is run out of /usr/bin or some other system bin directory
# it should be linked to and not copied. Things like java jar files are found
# relative to the canonical path of this script.
#

# USE the trap if you need to also do manual cleanup after the service is stopped,
#     or need to start multiple services in the one container

# Set environment variables.
JETTY_PREFIX=${JETTY_PREFIX:-/opt/jetty}
JETTY_HTTP_PORT=${JETTY_HTTP_PORT:-5601}

# Show environment variables.
echo "JETTY_PREFIX=${JETTY_PREFIX}"
echo "JETTY_HTTP_PORT=${JETTY_HTTP_PORT}"

# Start function
function start() {
  # Change http port.
  sed -e "s/^# jetty.http.port=.*/jetty.http.port=${JETTY_HTTP_PORT}/" ${JETTY_PREFIX}/start.ini > ${JETTY_PREFIX}/start.ini.tmp
  mv ${JETTY_PREFIX}/start.ini.tmp ${JETTY_PREFIX}/start.ini

  # Start Jetty.
  ${JETTY_PREFIX}/bin/jetty.sh start
}

trap "docker-stop.sh; exit 1" TERM KILL INT QUIT

# Start
start

# Start infinitive loop
while true
do
 tail -F /dev/null & wait ${!}
done
