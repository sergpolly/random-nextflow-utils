

// PREPARE OUTPUT DIRECTORY ...
myDir = file('/home/sergpolly/Desktop/bunchoftxt')

if ( myDir.exists() ) {
    println "Directory already exists: $myDir"
} else {
    result = myDir.mkdir()
    println result ? "OK" : "Cannot create directory: $myDir"
}


// re-use input stream of files to calculate hashes
// and for copying(+ more hash) 
Channel.fromPath( '../*.txt' ).into { CHNL_FILES_TO_HASH; CHNL_FILES_TO_COPY }


// given input stream of files calculate their hashes
// and stream them out along with the files themselves ...
process getmd5 {
   input:
      file f_in from CHNL_FILES_TO_HASH
   output:
      set file(f_in), stdout into CHNL_FILES_HASHES

   script:
     """
     md5sum ${f_in} | cut -f1 -d' ' | tr -d '\n'
     """
}

// now take those hashes with the files
// and perform copy along with verifications ...
process copy_n_verify_hash {
   input:
      set file(f_in), hash_in from CHNL_FILES_HASHES
   output:
      stdout into OUTPUT_HASH

   // f_out = "$myDir/$f_in"

   script:
     """
     FOUT=${myDir}/${f_in}
     cp ${f_in} \$FOUT
     HASH_OUT=\$(md5sum \$FOUT | cut -f1 -d' ' | tr -d '\n')
     if [ ${hash_in} = \$HASH_OUT ]; then
        exit 0
     else
        exit 1
     fi
     """
}


OUTPUT_HASH.println{"ccc: $it"}