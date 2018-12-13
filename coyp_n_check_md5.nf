

// PREPARE OUTPUT DIRECTORY ...
myDir = file('/home/venevs/Desktop/bunchoftxt')
result = myDir.mkdir()
println result ? "OK" : "Cannot create directory: $myDir"


Channel.fromPath( '../*.txt' ).into { INPUT_CHNL_MD5; OUTPUT_CHNL }

process getmd5 {
   input:
      file f from INPUT_CHNL_MD5
   output:
      set file(f), stdout into READY_INPUT_CHNL_MD5

   """
   md5sum ${f}
   """
}

READY_INPUT_CHNL_MD5
    .map { [it[0].getName(), it[1].split(' ')[0]] }
    .set{CLEANED_INPUT_CHNL_MD5}

// copy those files locally ...
OUTPUT_CHNL
    .map { f -> f.copyTo('/home/venevs/Desktop/bunchoftxt') }
    .into { OUTPUT_CHNL_MD5; OUTPUT_CHNL_CMP }


process getmd5_2 {
   input:
      file f from OUTPUT_CHNL_MD5
   output:
      set file(f), stdout into READY_OUTPUT_CHNL_MD5
   """
   md5sum ${f}
   """
}

READY_OUTPUT_CHNL_MD5
    .map { [it[0].getName(), it[1].split(' ')[0]] }
    .set{CLEANED_OUTPUT_CHNL_MD5}


CLEANED_INPUT_CHNL_MD5.join(CLEANED_OUTPUT_CHNL_MD5)
    .map{ [it[0], it[1], it[1]==it[2]] }
    .println{"ccc: $it"}
    