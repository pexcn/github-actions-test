#!/bin/sh
s
          changed_files='${{ steps.detect-changes.outputs.all_changed_files }}'
          changed_files_json=$(echo "$changed_files" | jq -Rc 'split(" ")')
          matrix_json=$(jq -c -n --argjson ctxs "$changed_files" '
            {
              include: [
                $ctxs[] | . as $ctx | {
                  BUILD_CONTEXT: $ctx,
                  TARGET_PLATFORMS: (
                    if (
                      [
                        "buildbot/bookworm",
                        "buildbot/bookworm-android",
                        "buildbot/bookworm-openwrt"
                      ] | index($ctx)
                    ) != null
                    then
                      "linux/amd64"
                    else
                      "linux/amd64,linux/arm64"
                    end
                  )
                }
              ]
            }
          ')
          echo "matrix_json=$matrix_json" >> $GITHUB_OUTPUT
