

// PREPARE OUTPUT DIRECTORY ...
myDir = file('/home/venevs/Desktop/bunchoftxt')

if ( myDir.exists() ) {
    println "Directory already exists: $myDir"
} else {
    result = myDir.mkdir()
    println result ? "OK" : "Cannot create directory: $myDir"
}


Channel.fromPath( '../*.txt' ).into { INPUT_CHNL_MD5; OUTPUT_CHNL }

process getmd5 {
   input:
      file f from INPUT_CHNL_MD5
   output:
      set file(f), stdout into READY_INPUT_CHNL_MD5

   """
   md5sum ${f} | cut -f1 -d' ' | tr -d '\n'
   """
}

READY_INPUT_CHNL_MD5
    .map { f,md5 -> [f.getName(), md5] }
    .set{CLEANED_INPUT_CHNL_MD5}

// copy those files locally ...
OUTPUT_CHNL
    .map { f -> f.copyTo("${myDir}") }
    .into { OUTPUT_CHNL_MD5; OUTPUT_CHNL_CMP }


process getmd5_2 {
   input:
      file f from OUTPUT_CHNL_MD5
   output:
      set file(f), stdout into READY_OUTPUT_CHNL_MD5
   """
   md5sum ${f} | cut -f1 -d' ' | tr -d '\n'
   """
}

READY_OUTPUT_CHNL_MD5
    .map { f,md5 -> [f.getName(), md5] }
    .set{CLEANED_OUTPUT_CHNL_MD5}


CLEANED_INPUT_CHNL_MD5.join(CLEANED_OUTPUT_CHNL_MD5)
    .map{ f, md5_1, md5_2 -> [ md5_1==md5_2, md5_1, f ] }
    .println{"ccc: $it"}
