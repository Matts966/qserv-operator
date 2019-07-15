#!/bin/sh

# See
# https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md#build-and-run-the-operator

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

operator-sdk build "$IMAGE"
sed "s|REPLACE_IMAGE|$IMAGE|g" "$DIR/deploy/operator.yaml.tpl" \
    > "$DIR/deploy/operator.yaml"
docker push "$IMAGE"