public without sharing class ViewPdf {

	public String atId {get; set;}
	public ContentVersion att {
		get {
			if (att == null) {
				atId = ApexPages.currentPage().getParameters().get('id');
				att = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :atId AND IsLatest = true ];
			}
			return att;
		}
		private set;
	}
	public String pdf {
		get {
			return EncodingUtil.Base64Encode(att.VersionData);
		}
	}
}