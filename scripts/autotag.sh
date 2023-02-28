#!/bin/bash


#Note that for tags, git does not store the branch from which a commit was tagged.



# Usage:
#  %autotag.sh
#
# find the latest release and increment the tag
usage() {
  echo "       "
  echo " Usage:"
  echo "       "
  exit 1
}


findLatestReleaseTag(){ latestRelease=`git describe --abbrev=0 --tags --always`; }


getNewVersion() {
 echo "getNewVersion"
 
 ##strip string "release-"
 #latestVersion=`echo $latestRelease | sed s/release-//g`
 
 #replace . with space so can split into an array
 VERSION_BITS=(${latestRelease//./ })
 
#get number parts and increase last one by 1
VNUM1=${VERSION_BITS[0]}
VNUM2=${VERSION_BITS[1]}
VNUM3=${VERSION_BITS[2]}
VNUM4=${VERSION_BITS[3]}
VNUM4=$((VNUM4+1))

#create new tag
NEW_TAG="$VNUM1.$VNUM2.$VNUM3.$VNUM4"

echo "Updating $VERSION to $NEW_TAG"
}

checkAndPushTag(){
  
  #get current hash and see if it already has a tag
  GIT_COMMIT=`git rev-parse HEAD`
  NEEDS_TAG=`git describe --contains $GIT_COMMIT  > /dev/null 2>&1`
  #only tag if no tag already (would be better if the git describe command above could have a silent option)
  if [ -z ${NEEDS_TAG} ]; then
      getNewVersion
      echo "Tagged with $NEW_TAG (Ignoring fatal:cannot describe - this means commit is untagged) "
      git tag $NEW_TAG
      git remote set-url origin https://jb-build:$GIT_JB_BUILD_Personal_Token@github.com/jitterbit/connectors.git
      git push --tags
  else
      echo "Already a tag on this commit"
  fi

}


#develop increments build#
#master increments major/minor

findLatestReleaseTag
checkAndPushTag

