trigger KnowledgeArticleVersion_tgr on Knowledge__kav (after insert, after update) {
    KnowledgeArticleVersion_tgr_cls helper = new KnowledgeArticleVersion_tgr_cls(); 
    helper.execute();
}