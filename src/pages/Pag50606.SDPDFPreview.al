page 50606 "PDF Preview"
{
    Caption = 'BeOCR - PDF Preview', Comment = 'ESP="Be OCR - Previsualización de documentos"';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "Document Header";

    layout
    {
        area(content)
        {
            field("Document"; Rec.Document)
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportPDF)
            {
                ApplicationArea = All;
                Caption = 'Import PDF';
                Image = Import;

                trigger OnAction()
                var
                    FileManagement: Codeunit "File Management";
                    FileName: Text;
                    InStr, ImgStream : InStream;
                    TempBlob: Codeunit "Temp Blob";
                    PDFDocument: Codeunit "PDF Document";
                    lblConfirmReplace: Label 'Do you want to replace the existing PDF file?';
                    lblDialogUpload: Label 'Select a PDF file to upload';
                begin

                    if Rec.Document.HasValue() then
                        if not Confirm(lblConfirmReplace) then
                            exit;
                    UploadIntoStream(lblDialogUpload, '', '', FileName, InStr);

                    TempBlob.CreateInStream(ImgStream);
                    PDFDocument.Load(InStr);
                    PDFDocument.ConvertPdfToImage(ImgStream, Enum::"Image Format"::Png, 1);
                    Clear(Rec.Document);
                    Rec.Document.ImportStream(ImgStream, FileName);

                    if not Rec.Modify(true) then
                        Rec.Insert(true);
                end;
            }
            action("Download Document")
            {
                ApplicationArea = All;
                Caption = 'Download Document';
                ToolTip = 'Download the document image from the Document field';
                Image = Download;
                trigger OnAction()
                var
                    InStream: InStream;
                    OutStream: OutStream;
                    FileName: Text;
                    TempBlob: Codeunit "Temp Blob";
                begin

                    if not Rec.Document.HasValue then
                        Error('No document available to download.');

                    OutStream := TempBlob.CreateOutStream();
                    Rec.Document.ExportStream(OutStream);
                    TempBlob.CreateInStream(InStream);
                    FileName := 'Document_' + Rec."No." + '.png';
                    DownloadFromStream(InStream, '', '', '', FileName);
                end;
            }

        }
    }
}