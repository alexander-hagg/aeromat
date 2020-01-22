for dir in case*
do 
	if [ -d "$dir" ]; then
		cd "$dir";
		echo "$dir";
		reconstructParMesh -constant;
		reconstructPar;
		cd "..";
		tar -cvzf "$dir".tar "$dir"
	fi
done