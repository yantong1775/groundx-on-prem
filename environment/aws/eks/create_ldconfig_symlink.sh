#!/bin/bash
# Define possible paths for ldconfig
LDCONFIG_PATHS=("/usr/sbin/ldconfig" "/sbin/ldconfig" "/bin/ldconfig" "/usr/bin/ldconfig")

# Check each path and create a symlink if ldconfig exists
for path in "$${LDCONFIG_PATHS[@]}"; do
  if [ -f "$$path" ]; then
    echo "Found ldconfig at $$path"
    ln -sf "$$path" /sbin/ldconfig.real
    break
  fi
done

# Verify symlink was created
if [ -L /sbin/ldconfig.real ]; then
  echo "Symbolic link created at /sbin/ldconfig.real"
else
  echo "Failed to find ldconfig in the specified paths."
fi