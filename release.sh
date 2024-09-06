#/bin/sh

OUTDIR=x1e-packages
REPO=linux-x1e



if [[ $1 == "--build-only" ]]; then
    echo "Building packages: $2"
    for pkg in $2 ; do
        cd $pkg
        PKGEXT=.pkg.tar.xz CARCH=aarch64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- nice -19 makepkg -sCA
        cd ..
    done
elif [[ $1 != "--skip-build" ]]; then
    echo 'Building packages...'
    for pkg in "linux-x1e" "x1e-firmware" "x1e-keyring" ; do
        cd $pkg
        PKGEXT=.pkg.tar.xz CARCH=aarch64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- nice -19 makepkg -sCA
        cd ..
    done
fi

[[ -d $OUTDIR ]] && rm -rf $OUTDIR
mkdir $OUTDIR && cd $OUTDIR

cp ../*/*.pkg.tar.xz ./

for pkg in *.pkg.tar.xz; do
    gpg --detach-sign "${pkg}"
done

repo-add --sign $REPO.db.tar.gz *.pkg.tar.xz

git tag -d packages && git tag packages && git push -f --tags

yes | gh release delete packages
gh release create packages --notes ""
gh release upload packages *
