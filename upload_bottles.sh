#!/bin/sh
# This is a hacky way to dump bottles from PR because Travis doesn't support artifacts
for bottle in *.bottle*.tar.gz; do
filename="${bottle/--/-}"
mv "${bottle}" "${filename}"
echo "Uploading ${filename}..."
curl -fsSF "file=@${filename}" https://file.io
echo "Done!"
done
