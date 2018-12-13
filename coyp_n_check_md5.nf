
myFileChannel = Channel.fromPath( '*.csv' )
myFileChannel.into {zzz;vvv}

process getmd5 {
   input:
      file f from vvv 
   output:
      set file(f), stdout into xxx 
      // file f into fff      
   """
   md5sum ${f}
   """
}
  
   
zzz.map {[it.getName(),it]}.set{aaa}
xxx.map {[it[0].getName(),it[1].split(' ')[0]]}.set{bbb}
// xxx.println{"$it"}

aaa.join(bbb).println{"~ $it"}