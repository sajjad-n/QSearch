class TermClass {
  String term, docName;
  var tf_raw, tf_wt, df, idf, tf_idf, normal_tf_idf;

  TermClass({
    this.term,
    this.tf_raw,
    this.tf_wt,
    this.df,
    this.idf,
    this.tf_idf,
    this.normal_tf_idf,
    this.docName
  });

}