files = Channel.fromPath('/pathpathpaht/output/coolers/library/*.cool')
// "XXXX-YY-ZZZZ-S3-R1__galGal5.1000.cool"

def ress = [20000, 40000, 200000]

chromosomes = Channel.from("chr10", "chr11", "chr12", "chr13", "chr14",
                            "chr15", "chr16", "chr17", "chr18", "chr19",
                            "chr1", "chr20", "chr21", "chr22", "chr23",
                            "chr24", "chr25", "chr26", "chr27", "chr28",
                            "chr2", "chr30", "chr31", "chr32", "chr33",
                            "chr3", "chr4", "chr5", "chr6", "chr7",
                            "chr8", "chr9", "chrM", "chrW", "chrZ")


files. \
  map{ f -> [f,f.getName()] }. \
  map{ f,fn ->  [f, ( fn =~ /([^\_]+)\_+(\w+)\.(\d+)\.cool/ )[0][1,3]].flatten() }. \
  filter{f,l,r -> ress.contains(r as Integer) }. \
  combine(chromosomes). \
  set { pa_li_re_ch }

////////////////////////////////////////////////////////
// this yields a stream of lists like this:
// [/path/libname__asm.res.cool, libname, res, chrXXX]
////////////////////////////////////////////////////////

process dump_cworld {
    executor 'lsf'
    cpus 2
    queue 'short'
    time { 45.m * task.attempt }
    maxForks 100
    errorStrategy 'retry'
    maxRetries 2
    memory '8 GB'
    beforeScript 'source activate cooler-env'
    publishDir "./maaaatricy/$lib/$res"

    input:
    set file(path), val(lib), val(res), val(chrom)  from pa_li_re_ch

    output:
    set file("${lib}.${res}.${chrom}.matrix"), stdout into myout

    script:
    """
    echo ${lib}.${res}.${chrom}.matrix
    cooltools dump_cworld --region ${chrom} ${path} ${lib}.${res}.${chrom}.matrix
    """

 }


// printing something just for fun ...
// actual output would go to publishDir ...
myout.map{x -> x[1]}.subscribe { println "xxx: $it" }





