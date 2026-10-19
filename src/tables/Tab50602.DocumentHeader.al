table 50601 "Document Header"
{
    Caption = 'Document Header', Comment = 'ESP="Cabecera de Documento"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "ID API"; Text[60])
        {
            Caption = 'ID API', Comment = 'ESP="ID API"';
            DataClassification = SystemMetadata;
        }
        field(3; "No."; Text[50])
        {
            Caption = 'No.', Comment = 'ESP="Nº"';
            DataClassification = CustomerContent;
        }
        field(4; "Invoice Date"; text[30])
        {
            Caption = 'Invoice Date', Comment = 'ESP="Fecha Factura"';
            DataClassification = CustomerContent;
        }
        field(5; NIF; Text[20])
        {
            Caption = 'NIF', Comment = 'ESP="NIF"';
            DataClassification = CustomerContent;
        }
        field(6; Name; Text[290])
        {
            Caption = 'Name', Comment = 'ESP="Nombre"';
            DataClassification = CustomerContent;
        }
        field(7; "VAT Amount"; Text[30])
        {
            Caption = 'VAT Amount', Comment = 'ESP="Importe IVA"';
            DataClassification = CustomerContent;
        }
        field(8; Total; Text[30])
        {
            Caption = 'Total', Comment = 'ESP="Total"';
            DataClassification = CustomerContent;
        }
        field(9; Document; Media)
        {
            Caption = 'Document PNG', Comment = 'ESP="PNG del Documento"';
            DataClassification = CustomerContent;
            ExtendedDatatype = Document;
        }
        field(10; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.', Comment = 'ESP="Nº de Proveedor"';
            DataClassification = ToBeClassified;
            TableRelation = vendor;

        }
        field(11; "File Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(12; Response; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Status; Enum "Document Status")
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Document PDF"; Blob)
        {
            Caption = 'Document PDF', Comment = 'ESP="PDF del Documento"';
            DataClassification = CustomerContent;

        }
        field(15; "Document 2"; Media)
        {
            Caption = 'Document PNG (Page 2)', Comment = 'ESP="PNG del Documento (Página 2)"';
            DataClassification = CustomerContent;
            ExtendedDatatype = Document;
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
    [TryFunction]
    procedure insertDocument(idAPI: text[60]; ResponseText: Text; base64Text: Text)
    var
        DocumentHeader: Record "Document Header";
        DocumentLine: Record "Document Line";
        Vendor: Record Vendor;

        ResultBlob: Codeunit "Temp Blob";
        jsonDocumentResponse: JsonObject;
        jsonArrayItems: JsonArray;
        jsonObjectItem: JsonObject;
        i: Integer;
        OutStream: OutStream;
        InStream: InStream;
        TempBlob: Codeunit "Temp Blob";
        Base64: Codeunit "Base64 Convert";
        ImageBase64: Codeunit "Image Helpers";
        typeImage: text;
    begin
        DocumentHeader.reset();
        DocumentHeader.setrange("ID API", idAPI);

        if not DocumentHeader.FindFirst() then begin
            DocumentHeader.Init();
            DocumentHeader."ID API" := idAPI;
            DocumentHeader.Insert(true);
        end;

        ResponseText := ResponseText.Replace('\n', '  ');
        ResponseText := ResponseText.Replace('\"', '"');
        ResponseText := DelChr(ResponseText, '<>', '"');
        // Parse JSON directly from text


        //DownloadResponseAsFile(ResponseText);
        if not jsonDocumentResponse.ReadFrom(ResponseText) then
            Error('Invalid JSON format in response.');
        if jsonDocumentResponse.Contains('Error') then
            error(jsonDocumentResponse.GetText('Error'));
        DocumentHeader."No." := GetText('invoice_number', jsonDocumentResponse, '');
        DocumentHeader."Invoice Date" := GetText('date', jsonDocumentResponse, format(today()));
        DocumentHeader.NIF := GetText('nif', jsonDocumentResponse, '');
        if DocumentHeader.NIF <> '' then begin
            Vendor.Reset();
            Vendor.setrange("VAT Registration No.", DocumentHeader.NIF);
            if Vendor.FindFirst() then
                DocumentHeader."Vendor No." := Vendor."No.";
        end;
        DocumentHeader.Name := GetText('vendor_name', jsonDocumentResponse, '');
        // Extract and decode base64 image

        if base64Text <> '' then begin
            /* if IsPdfBase64(base64Text) then begin
                 // Es un PDF, convertir a JPG
                 ResultBlob := ConvertBase64PdfToJpg(base64Text);
                 ResultBlob.CreateInStream(InStream);

                 // Importar la imagen JPG
                 Clear(DocumentHeader.Document);
                 DocumentHeader.Document.ImportStream(InStream, 'image.jpg', 'image/jpeg');
             end else begin
                 // Es una imagen, importar directamente
                 */
            // Clear(DocumentHeader.Document);
            //  TempBlob.CreateOutStream(OutStream);
            //  Base64.FromBase64(Base64Text, OutStream);
            //  TempBlob.CreateInStream(InStream);
            //   DocumentHeader.Document.ImportStream(InStream, 'image.jpg', 'image/jpeg');
            //end;
        end;


        jsonArrayItems := jsonDocumentResponse.GetArray('items');
        for i := 0 to jsonArrayItems.Count - 1 do begin
            jsonObjectItem := jsonArrayItems.GetObject(i);
            DocumentLine.Init();
            DocumentLine.ID := DocumentHeader.ID;
            DocumentLine."Line No." := i + 1;
            if DocumentLine.Insert() then;
            DocumentLine.type := DocumentLine.Type::" ";
            DocumentLine."No. Import" := GetText('no', jsonObjectItem, '');
            DocumentLine.validate(Name, GetText('name', jsonObjectItem, '0'));
            DocumentLine.validate(Quantity, GetText('quantity', jsonObjectItem, '0'));
            DocumentLine.validate(Price, GetText('price', jsonObjectItem, '0'));
            DocumentLine.validate(SubTotal, GetText('subtotal', jsonObjectItem, '0'));
            DocumentLine.validate("% Discount", GetText('% discount', jsonObjectItem, '0'));
            DocumentLine.Modify();
        end;
        DocumentHeader."VAT Amount" := GetText('vat_amount', jsonDocumentResponse, '0');
        DocumentHeader.Total := GetText('total', jsonDocumentResponse, '0');
        DocumentHeader.Modify();
    end;

    local procedure GetText(param: Text; jsonObject: JsonObject; defaultValue: Text): text
    var
        jsonObjectText: Text;
    begin
        if jsonObject.Contains(param) then
            jsonObjectText := jsonObject.GetText(param)
        else
            jsonObjectText := defaultValue;
        exit(jsonObjectText);
    end;

    local procedure DownloadResponseAsFile(ResponseText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        response: text;
    begin
        if ResponseText = '' then
            exit;

        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(ResponseText);
        TempBlob.CreateInStream(InStream);
        response := 'response.json';
        DownloadFromStream(InStream, 'Download', '', 'JSON Files (*.json)|*.json', response);
    end;
    /*
        local procedure ConvertBase64PdfToJpg(base64Text: Text): Codeunit "Temp Blob"
        var
            TempBlob: Codeunit "Temp Blob";
            TempBlobImage: Codeunit "Temp Blob";
            Base64: Codeunit "Base64 Convert";
            PDFDocument: Codeunit "PDF Document";
            InStream: InStream;
            ImgStream: InStream;
            OutStream: OutStream;
        begin
            // Decodificar Base64
            TempBlob.CreateOutStream(OutStream);
            Base64.FromBase64(base64Text, OutStream);

            TempBlob.CreateInStream(InStream);

            // Cargar y convertir PDF a imagen JPG
            PDFDocument.Load(InStream);
            TempBlobImage.CreateInStream(ImgStream);
            PDFDocument.ConvertPdfToImage(ImgStream, Enum::"Image Format"::Jpeg, 1);  // Convertir página 1 a JPEG
            exit(TempBlobImage);
        end;*/

    procedure UploadDocument()

    var
        ResponseText: Text;
        ResponseStream: OutStream;
        FileInStream: InStream;
        ImgStream: InStream;
        OutStream: OutStream;
        DocumentHeader: Record "Document Header";
        FileName: Text;
        FileExtension: Text;
        DocumentText: Text;
        PDFDocument: Codeunit "PDF Document";
        TempBlob: Codeunit "Temp Blob";
        TempBlobImage: Codeunit "Temp Blob";
        OcrIntegration: Codeunit "OCR Integration";
        UploadMsg: Label 'Please select a document to upload (PDF, JPG, JPEG or PNG).', Comment = 'ESP="Por favor, seleccione un documento para cargar (PDF, JPG, JPEG o PNG)."';
        ProcessingMsg: Label 'Processing document...';
        SuccessMsg: Label 'Document uploaded and processed successfully. Document ID: %1', Comment = 'ESP="Documento cargado y procesado exitosamente. ID del documento: %1"';
        InvalidFileMsg: Label 'Invalid file format. Please upload a PDF, JPG, JPEG or PNG file.', Comment = 'ESP="Formato de archivo inválido. Por favor, cargue un archivo PDF, JPG, JPEG o PNG."';
        IsPdf: Boolean;
    begin
        TempBlob.CreateInStream(FileInStream);
        // Request file from user - accept PDF, JPG, JPEG, PNG
        if not File.UploadIntoStream(UploadMsg, '', 'All Supported Files (*.pdf;*.jpg;*.jpeg;*.png)|*.pdf;*.jpg;*.jpeg;*.png|PDF Files (*.pdf)|*.pdf|Image Files (*.jpg;*.jpeg;*.png)|*.jpg;*.jpeg;*.png', FileName, FileInStream) then
            exit;

        // Get file extension
        FileExtension := LowerCase(FileName.Substring(FileName.LastIndexOf('.') + 1));

        // Validate file extension
        if not ((FileExtension = 'pdf') or (FileExtension = 'jpg') or (FileExtension = 'jpeg') or (FileExtension = 'png')) then begin
            Message(InvalidFileMsg);
            exit;
        end;

        IsPdf := FileExtension = 'pdf';

        // Create a new Document Ledger Entry
        DocumentHeader.Init();
        DocumentHeader.Insert(true);

        if IsPdf then begin
            // Store the PDF in the Document PDF field
            DocumentHeader."Document PDF".CreateOutStream(OutStream);
            CopyStream(OutStream, FileInStream);

            // Convert PDF first page to PNG
            PDFDocument.Load(FileInStream);
            TempBlobImage.CreateInStream(ImgStream);
            PDFDocument.ConvertPdfToImage(ImgStream, Enum::"Image Format"::Png, 1);
            Clear(DocumentHeader.Document);
            DocumentHeader.Document.ImportStream(ImgStream, FileName);
        end else begin

            Clear(DocumentHeader.Document);
            DocumentHeader.Document.ImportStream(FileInStream, FileName);
            DocumentHeader."Document PDF".CreateOutStream(OutStream);
            CopyStream(OutStream, FileInStream);

        end;

        DocumentHeader."File Name" := FileName;
        DocumentHeader.Modify();

        Message(ProcessingMsg);
        OcrIntegration.SetMethod(Enum::"Method OCR API"::ocr);
        ResponseText := OcrIntegration.ProcessDocumentOCRByDocumentEntry(DocumentHeader);
        Clear(DocumentHeader.Response);
        DocumentHeader.Response.CreateOutStream(ResponseStream, TEXTENCODING::UTF8);
        ResponseStream.WriteText(ResponseText);

        DocumentHeader.Modify();
        // Display success message with the document ID from the API response
        Message(SuccessMsg, DocumentHeader."ID API");
    end;

    /// <summary>
    /// Receives a PDF encoded in Base64, keeps the original PDF in "Document PDF",
    /// converts the first page to PNG into Document and the second page (if any) into "Document 2".
    /// </summary>
    procedure SetDocumentFromBase64(DocumentBase64: Text)
    var
        TempBlobPdf: Codeunit "Temp Blob";
        TempBlobPage1: Codeunit "Temp Blob";
        TempBlobPage2: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        PDFDocument: Codeunit "PDF Document";
        PdfOutStream: OutStream;
        PdfInStream: InStream;
        Page1InStream: InStream;
        Page2InStream: InStream;
        PageCount: Integer;
        NotPdfErr: Label 'The Document String must be a PDF file encoded in Base64.', Comment = 'ESP="El Document String debe ser un fichero PDF codificado en Base64."';
        ConvertPageErr: Label 'Page %1 of the PDF could not be converted to an image.', Comment = 'ESP="No se ha podido convertir a imagen la página %1 del PDF."';
    begin
        // Remove optional data URI prefix (data:application/pdf;base64,)
        if DocumentBase64.StartsWith('data:') and DocumentBase64.Contains(',') then
            DocumentBase64 := DocumentBase64.Substring(DocumentBase64.IndexOf(',') + 1);
        DocumentBase64 := DelChr(DocumentBase64, '<>', ' ');
        if DocumentBase64 = '' then
            exit;

        // '%PDF' in Base64 starts with 'JVBER'
        if not DocumentBase64.StartsWith('JVBER') then
            Error(NotPdfErr);

        TempBlobPdf.CreateOutStream(PdfOutStream);
        Base64Convert.FromBase64(DocumentBase64, PdfOutStream);

        // Keep the original PDF
        Clear("Document PDF");
        "Document PDF".CreateOutStream(PdfOutStream);
        TempBlobPdf.CreateInStream(PdfInStream);
        CopyStream(PdfOutStream, PdfInStream);

        TempBlobPdf.CreateInStream(PdfInStream);
        PageCount := PDFDocument.GetPdfPageCount(PdfInStream);

        TempBlobPdf.CreateInStream(PdfInStream);
        PDFDocument.Load(PdfInStream);

        // Page 1 -> Document
        Clear(Document);
        TempBlobPage1.CreateInStream(Page1InStream);
        if not PDFDocument.ConvertPdfToImage(Page1InStream, Enum::"Image Format"::Png, 1) then
            Error(ConvertPageErr, 1);
        Document.ImportStream(Page1InStream, 'Page1.png', 'image/png');

        // Page 2 -> Document 2
        Clear("Document 2");
        if PageCount >= 2 then begin
            TempBlobPage2.CreateInStream(Page2InStream);
            if not PDFDocument.ConvertPdfToImage(Page2InStream, Enum::"Image Format"::Png, 2) then
                Error(ConvertPageErr, 2);
            "Document 2".ImportStream(Page2InStream, 'Page2.png', 'image/png');
        end;
    end;

    trigger OnDelete()
    var
        DocumentLine: Record "Document Line";
    begin
        DocumentLine.setrange(ID, Rec.ID);
        DocumentLine.DeleteAll();
    end;

    trigger OnInsert()
    var
        ConfigAPIOCR: Record "BeOCR Setup";
        SerieMgt: Codeunit "No. Series";
    begin
        ConfigAPIOCR.Get();
        ConfigAPIOCR.TestField("Document Header Serie");
        ID := SerieMgt.GetNextNo(ConfigAPIOCR."Document Header Serie");
    end;
    /*
        local procedure IsPdfBase64(base64Text: Text): Boolean
        var
            TempBlob: Codeunit "Temp Blob";
            Base64: Codeunit "Base64 Convert";
            InStream: InStream;
            Byte1: Byte;
            Byte2: Byte;
            Byte3: Byte;
            Byte4: Byte;
            OutStream: OutStream;
        begin
            exit(base64Text.StartsWith('Lzlq'));
        end;
        */
}
