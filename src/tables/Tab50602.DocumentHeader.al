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
            trigger OnValidate()
            var
                Vendor: record Vendor;
            begin
                if "Vendor No." <> '' then begin
                    vendor.get("Vendor No.");
                    rec.Name := Vendor.name;
                    rec.nif := Vendor."VAT Registration No.";
                end;
            end;
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


        if not jsonDocumentResponse.ReadFrom(ResponseText) then
            Error('Invalid JSON format in response.');
        if jsonDocumentResponse.Contains('Error') then
            error(jsonDocumentResponse.GetText('Error'));
        DocumentHeader."No." := jsonDocumentResponse.GetText('invoice_number');
        DocumentHeader."Invoice Date" := jsonDocumentResponse.GetText('date');
        DocumentHeader.NIF := jsonDocumentResponse.GetText('nif');
        if DocumentHeader.NIF <> '' then begin
            Vendor.Reset();
            Vendor.setrange("VAT Registration No.", DocumentHeader.NIF);
            if Vendor.FindFirst() then
                DocumentHeader."Vendor No." := Vendor."No.";
        end;
        DocumentHeader.Name := jsonDocumentResponse.GetText('vendor_name');
        // Extract and decode base64 image

        if base64Text <> '' then begin
            Clear(DocumentHeader.Document);
            TempBlob.CreateOutStream(OutStream);
            Base64.FromBase64(Base64Text, OutStream);
            TempBlob.CreateInStream(InStream);
            DocumentHeader.Document.ImportStream(InStream, 'image.jpg', 'image/jpeg');
        end;


        jsonArrayItems := jsonDocumentResponse.GetArray('items');
        for i := 0 to jsonArrayItems.Count - 1 do begin
            jsonObjectItem := jsonArrayItems.GetObject(i);
            DocumentLine.Init();
            DocumentLine.ID := DocumentHeader.ID;
            DocumentLine."Line No." := i + 1;
            if DocumentLine.Insert() then;
            DocumentLine.type := DocumentLine.Type::" ";
            DocumentLine."No. Modify" := jsonObjectItem.GetText('no');
            DocumentLine.validate(Name, jsonObjectItem.GetText('name'));
            DocumentLine.validate(Quantity, jsonObjectItem.GetText('quantity'));
            DocumentLine.validate(Price, jsonObjectItem.GetText('price'));
            DocumentLine.validate(SubTotal, jsonObjectItem.GetText('subtotal'));
            DocumentLine.Modify();
        end;

        DocumentHeader."VAT Amount" := jsonDocumentResponse.GetText('vat_amount');
        DocumentHeader.Total := jsonDocumentResponse.GetText('total');

        DocumentHeader.Modify();
    end;

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
}
