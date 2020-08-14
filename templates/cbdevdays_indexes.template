CREATE INDEX idx_doc_type ON `{{BUCKET}}`(doc.`type`);
CREATE INDEX idx_docType ON `{{BUCKET}}`(docType);
CREATE INDEX idx_customer_basic ON `{{BUCKET}}`(username, custId, (custName.firstName), (custName.lastname)) WHERE doc.`type`="customer";
CREATE INDEX idx_user_pw on `{{BUCKET}}`(username, userId, `password`) WHERE docType="user";
