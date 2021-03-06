--Ma hoa bang Password: Dữ liệu quan trọng cần mã hóa

select EncryptedData = EncryptByPassPhrase('P@ssw0rd', N'Dữ liệu quan trọng cần mã hóa' ) 

--Giai ma hoa bang Password:

select convert(nvarchar(100),DecryptByPassPhrase('P@ssw0rd', 0x0100000027C5A152A7F7D7AA6F185C9AA60DB6FBE438F63EA5830F4B9AED53C2A6000D67F09C7810213DB4E0E3B6AD2C4D5426FABD4D9322EAACB1400DCA843294C9382FF0CB213C5E6ED37881A7B0846B3F2EF0))
 
---------------------------------------------------------------

-- tao Database Master key bằng password
USE AdventureWorks
GO
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id=101)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'dkjuw4r$$#1946kcj$ngJKL95Q'
GO

-- Tao Certificate ten HRCert
CREATE CERTIFICATE HRCert
WITH SUBJECT = 'Job Candidate Comments'
GO

-- Tao SymetricKey ten CommentKey 
CREATE SYMMETRIC KEY CommentKey
WITH ALGORITHM = DES
ENCRYPTION BY CERTIFICATE HRCert
GO

-- Them 2 cot ten NhanXet1 lưu dữ liệu đã mã hóa, NhanXet2 lưu dữ liệu sẽ giải mã 
-- vao bang du lieu HumanResources.JobCandidate

USE AdventureWorks

ALTER TABLE HumanResources.JobCandidate
ADD NhanXet1 varbinary(8000)
GO

ALTER TABLE HumanResources.JobCandidate
ADD NhanXet2 nvarchar(100)
GO

-- Dung Certificate HRCert de giai ma SymmetricKey CommentKey, 
-- Sau do dung SymetricKey ma hoa chuoi 'Chưa có ý kiến nhận xét' ghi vao cot NhanXet1
OPEN SYMMETRIC KEY CommentKey
DECRYPTION BY CERTIFICATE HRCert
UPDATE HumanResources.JobCandidate
SET NhanXet1 = EncryptByKey(Key_GUID('CommentKey'), N'Chưa có ý kiến nhận xét')
GO

-- Mo du lieu de thay cot Comments da duoc ma hoa vào cột NhanXet1
SELECT JobCandidateID,ModifiedDate, NhanXet1, NhanXet2 FROM HumanResources.JobCandidate

-- Dung Certificate HRCert de giai ma SymmetricKey CommentKey, 
-- Sau do dung SymetricKey de gia ma du lieu trong cot NhanXet1
 
OPEN SYMMETRIC KEY CommentKey
DECRYPTION BY CERTIFICATE HRCert;

UPDATE HumanResources.JobCandidate
SET NhanXet2 = CONVERT(nvarchar, DecryptByKey(NhanXet1))
GO

-- Mo du lieu de thay cot Nhanxet1 da duoc giai hoa vao cot NhanXet2

SELECT JobCandidateID,ModifiedDate, NhanXet1, NhanXet2 FROM HumanResources.JobCandidate


-- xoa cot NhanXet
ALTER TABLE HumanResources.JobCandidate
DROP COLUMN NhanXet1, NhanXet2
GO

-- Thu ket qua sau khi xoa cot NhanXet1, NhanXet2
SELECT * FROM HumanResources.JobCandidate

