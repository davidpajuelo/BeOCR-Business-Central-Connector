codeunit 50600 "OCR Integration"
{
    Description = 'Handles OCR API integration and document processing';

    var
        Error0001Lbl: Label 'Config API OCR not found. Please configure the API settings.', Comment = 'ESP="Configuración API OCR no encontrada. Establezca los parámetros de API."';
        Error0002Lbl: Label 'API URL not configured in Config API OCR.', Comment = 'ESP="URL de API no configurada en Configuración API OCR."';
        Error0003Lbl: Label 'API Token not configured in Config API OCR.', Comment = 'ESP="Token de API no configurado en Configuración API OCR."';
        Error0004Lbl: Label 'Failed to send request to OCR API.', Comment = 'ESP="Error al enviar solicitud a la API de OCR."';
        Error0005Lbl: Label 'OCR API returned error: %1', Comment = 'ESP="La API de OCR devolvió un error: %1"';

    procedure SetMethod(pMethodOCR: enum "Method OCR API")
    begin
        methodOCR := pMethodOCR;
    end;

    procedure ProcessDocumentOCR(DocumentInStream: InStream): Text
    var
        ConfigAPIRecord: Record "BeOCR Setup";
        JsonObject: JsonObject;
        RequestText: Text;
        Token: Text;
        PdfBase64: Text;
        ResponseText: Text;
        Base64Convert: Codeunit "Base64 Convert";
        RestHelper: Codeunit "API Rest Helper";
    begin
        ConfigAPIRecord.GET();
        RestHelper.Initialize('POST', ConfigAPIRecord.URL + '/' + format(methodOCR));
        RestHelper.AddDefaultRequestHeaders();
        JsonObject.Add('token', ConfigAPIRecord."API Key");

        PdfBase64 := Base64Convert.ToBase64(DocumentInStream);
        JsonObject.add('document', PdfBase64);
        JsonObject.WriteTo(RequestText);
        RestHelper.AddBody(RequestText);
        RestHelper.SetContentType('application/json');
        RestHelper.Send(RequestText);
        ResponseText := RestHelper.GetResponseContentAsText();
        exit(ResponseText);
    end;

    procedure getDocumentsOCR(): text
    var
        ConfigAPIRecord: Record "BeOCR Setup";
        JsonObject: JsonObject;
        RequestText: Text;
        Token: Text;
        PdfBase64: Text;
        ResponseText: Text;
        Base64Convert: Codeunit "Base64 Convert";
        RestHelper: Codeunit "API Rest Helper";
    begin
        ConfigAPIRecord.GET();
        RestHelper.Initialize('POST', ConfigAPIRecord.URL + '/' + format(methodOCR));
        RestHelper.AddDefaultRequestHeaders();
        JsonObject.Add('token', ConfigAPIRecord."API Key");
        JsonObject.WriteTo(RequestText);
        RestHelper.AddBody(RequestText);
        RestHelper.SetContentType('application/json');
        RestHelper.Send(RequestText);
        ResponseText := RestHelper.GetResponseContentAsText();
        exit(ResponseText);
    end;

    procedure GetDocumentOCR(logId: text): Text
    var
        ConfigAPIRecord: Record "BeOCR Setup";
        JsonObject: JsonObject;
        RequestText: Text;
        Token: Text;
        PdfBase64: Text;
        ResponseText: Text;
        Base64Convert: Codeunit "Base64 Convert";
        RestHelper: Codeunit "API Rest Helper";
    begin
        ConfigAPIRecord.GET();
        RestHelper.Initialize('POST', ConfigAPIRecord.URL + '/' + format(methodOCR));
        RestHelper.AddDefaultRequestHeaders();
        JsonObject.Add('token', ConfigAPIRecord."API Key");
        JsonObject.add('apiKeyName', '');
        JsonObject.add('log_id', logId);
        JsonObject.WriteTo(RequestText);
        RestHelper.AddBody(RequestText);
        RestHelper.SetContentType('application/json');
        RestHelper.Send(RequestText);
        ResponseText := RestHelper.GetResponseContentAsText();
        exit(ResponseText);
    end;

    procedure ProcessDocumentOCRByDocumentEntry(var DocumentHeader: Record "Document Header"): Text
    var
        TempBlob: Codeunit "Temp Blob";

        ApiResponse: Text;
        OutStream: OutStream;
        InStream: InStream;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        LogocrId: Text;
    begin
        // Get input stream from the document media field
        DocumentHeader."Document PDF".CreateInStream(InStream);
        // Process the document and get the response
        ApiResponse := ProcessDocumentOCR(InStream);

        // Store the response in the blob field
        DocumentHeader.Response.CreateOutStream(OutStream);
        OutStream.WriteText(ApiResponse);

        // Parse the API response to extract logocr_id
        if JsonObject.ReadFrom(ApiResponse) then begin
            if JsonObject.Get('logocr_id', JsonToken) then
                LogocrId := JsonToken.AsValue().AsText();
            DocumentHeader."ID API" := LogocrId;
        end;

        // Update the status
        DocumentHeader.Status := DocumentHeader.Status::Send;

        // Save the changes
        DocumentHeader.Modify();

        exit(ApiResponse);
    end;

    local procedure RecordToJsonArray(RecordVariable: Variant) JsonArrayResult: JsonArray
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        JsonObject: JsonObject;
        i: Integer;
    begin
        RecRef.GetTable(RecordVariable);
        if RecRef.FindSet() then
            repeat
                Clear(JsonObject);
                FieldRef := RecRef.Field(1);
                JsonObject.Add('code', Format(FieldRef.Value()));
                case RecRef.Name of
                    'Vendor':
                        FieldRef := RecRef.Field(2);
                    'Item':
                        FieldRef := RecRef.Field(3);
                end;
                JsonObject.Add('name', Format(FieldRef.Value()));
                case RecRef.Name of
                    'Vendor':
                        begin
                            FieldRef := RecRef.Field(86);
                            JsonObject.Add('nif', Format(FieldRef.Value()));
                        end;
                    'Item':
                        JsonObject.Add('nif', '');
                end;
                JsonArrayResult.Add(JsonObject);
            until RecRef.Next() = 0;
        exit(JsonArrayResult);
    end;


    procedure SearchProductByName(ProductName: Text): Text
    var
        ConfigAPIRecord: Record "BeOCR Setup";
        Item: Record Item;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        RequestText: Text;
        ResponseText: Text;
        RestHelper: Codeunit "API Rest Helper";
    begin
        ConfigAPIRecord.GET();

        if ConfigAPIRecord.URL = '' then
            Error(Error0002Lbl);

        if ConfigAPIRecord."API Key" = '' then
            Error(Error0003Lbl);

        // Obtener productos no bloqueados
        Item.SetRange(Blocked, false);
        JsonArray := RecordToJsonArray(Item);

        // Crear el objeto JSON con el nombre y el array de productos
        JsonObject.Add('token', ConfigAPIRecord."API Key");
        JsonObject.Add('record_name', ProductName);
        JsonObject.Add('record_nif', '');
        JsonObject.Add('records', JsonArray);

        JsonObject.WriteTo(RequestText);

        // Hacer la llamada al API
        RestHelper.Initialize('POST', ConfigAPIRecord.URL + '/' + format(methodOCR));
        RestHelper.AddDefaultRequestHeaders();
        //RestHelper.AddRequestHeader('Authorization', 'Bearer ' + ConfigAPIRecord.Token);
        RestHelper.AddBody(RequestText);
        RestHelper.SetContentType('application/json');

        RestHelper.Send(RequestText);
        ResponseText := RestHelper.GetResponseContentAsText();
        exit(ResponseText);
    end;

    procedure SearchVendorByNameAndNif(recordName: Text; recordNif: Text): Text
    var
        ConfigAPIRecord: Record "BeOCR Setup";
        Vendor: Record Vendor;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        RequestText: Text;
        ResponseText: Text;
        RestHelper: Codeunit "API Rest Helper";
    begin
        ConfigAPIRecord.GET();

        if ConfigAPIRecord.URL = '' then
            Error(Error0002Lbl);

        if ConfigAPIRecord."API Key" = '' then
            Error(Error0003Lbl);

        // Obtener proveedores no bloqueados
        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
        JsonArray := RecordToJsonArray(Vendor);

        // Crear el objeto JSON con el nombre, NIF y el array de proveedores
        JsonObject.Add('token', ConfigAPIRecord."API Key");
        JsonObject.Add('record_name', recordName);
        JsonObject.Add('record_nif', recordNif);
        JsonObject.Add('records', JsonArray);

        JsonObject.WriteTo(RequestText);

        // Hacer la llamada al API
        RestHelper.Initialize('POST', ConfigAPIRecord.URL + '/' + format(methodOCR));
        RestHelper.AddDefaultRequestHeaders();
        //RestHelper.AddRequestHeader('Authorization', 'Bearer ' + ConfigAPIRecord.Token);
        RestHelper.AddBody(RequestText);
        RestHelper.SetContentType('application/json');

        RestHelper.Send(RequestText);
        ResponseText := RestHelper.GetResponseContentAsText();
        exit(ResponseText);
    end;



    procedure ConvertDocumentToPurchase(DocumentID: Text[60]; DocumentType: Enum "Purchase Document Type"): Code[20]
    var
        DocumentHeader: Record "Document Header";
        DocumentLine: Record "Document Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineNo: Integer;
        PostingDate: Date;
    begin
        // Obtener el Document Header por ID API
        if not DocumentHeader.Get(DocumentID) then
            Error('Document Header with ID API %1 not found.', DocumentID);
        CheckDocument(DocumentHeader);
        // Inicializar el Purchase Header
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := DocumentType;

        // Convertir la fecha de texto a formato de fecha
        if DocumentHeader."Invoice Date" <> '' then
            PostingDate := ConvertTextToDate(DocumentHeader."Invoice Date")
        else
            PostingDate := Today();

        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Document Date", PostingDate);
        PurchaseHeader.validate(PurchaseHeader."Buy-from Vendor No.", DocumentHeader."Vendor No.");
        PurchaseHeader.Validate("Vendor Invoice No.", DocumentHeader."No.");
        //PurchaseHeader.Validate("VAT Registration No.", DocumentHeader.NIF);

        // Insertar el Purchase Header (esto generará el siguiente número de documento)
        PurchaseHeader.Insert(true);

        // Obtener todas las Document Lines asociadas al Document Header
        DocumentLine.Reset();
        DocumentLine.SetRange(ID, DocumentID);

        if DocumentLine.FindSet() then begin
            LineNo := 10000;
            repeat
                // Crear una nueva Purchase Line
                PurchaseLine.Init();
                PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Line No." := LineNo;
                PurchaseLine.Type := DocumentLine.Type;

                // Insertar la línea
                if PurchaseLine.Insert(true) then;

                // Validar los campos de la Purchase Line
                PurchaseLine.Validate("No.", DocumentLine."No.");
                PurchaseLine.Validate(Quantity, ConvertTextToDecimal(DocumentLine.Quantity));
                PurchaseLine.Validate("Direct Unit Cost", ConvertTextToDecimal(DocumentLine.Price));
                PurchaseLine.validate(Description, DocumentLine.Name);

                // Guardar los cambios
                PurchaseLine.Modify();

                LineNo += 10000;
            until DocumentLine.Next() = 0;
        end;

        exit(PurchaseHeader."No.");
    end;

    procedure OpenDocumentCardPurchase(PurchaseOrderNo: Code[20]; DocumentType: Enum "Purchase Document Type")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoice: Page "Purchase Invoice";
        PurchaseOrder: PAge "Purchase Order";
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", DocumentType);
        PurchaseHeader.SetRange("No.", PurchaseOrderNo);
        if PurchaseHeader.FindFirst() then begin
            if DocumentType = DocumentType::Invoice then begin
                PurchaseInvoice.SetRecord(PurchaseHeader);
                PurchaseInvoice.Run();
            end else if DocumentType = DocumentType::Order then begin
                PurchaseOrder.SetRecord(PurchaseHeader);
                PurchaseOrder.Run();
            end;
        end;
    end;

    procedure OpenDocumentListPurchase(VendorPurchaseInvoiceNo: Code[20]; DocumentType: Enum "Purchase Document Type")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoices: Page "Purchase Invoices";
        PurchaseOrders: Page "Purchase Order List";
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Vendor Invoice No.", VendorPurchaseInvoiceNo);
        if DocumentType = DocumentType::Invoice then begin
            PurchaseInvoices.SetTableView(PurchaseHeader);
            PurchaseInvoices.Run();
        end else if DocumentType = DocumentType::Order then begin
            PurchaseOrders.SetTableView(PurchaseHeader);
            PurchaseOrders.Run();
        end;
    end;

    local procedure CheckDocument(DocumentHeader: Record "Document Header")
    var
        DocumentLine: Record "Document Line";
        DateEvaluate: Date;
        Error0001Lbl: Label 'The Line %1';
    begin
        DocumentHeader.TestField("Invoice Date");
        Evaluate(DateEvaluate, DocumentHeader."Invoice Date");
        DocumentHeader.TestField("Vendor No.");
        DocumentLine.Reset();
        DocumentLine.SetRange(ID, DocumentHeader.ID);

        if DocumentLine.FindSet() then
            repeat
                DocumentLine.TestField(Type);
                DocumentLine.Validate("No.");
            until DocumentLine.Next() = 0;
    end;

    local procedure ConvertTextToDate(TextDate: Text): Date
    var
        DateVar: Date;
    begin
        if TextDate = '' then
            exit(Today());

        Evaluate(DateVar, TextDate);
        exit(DateVar);
    end;

    local procedure ConvertTextToDecimal(TextValue: Text): Decimal
    var
        DecimalVar: Decimal;
    begin
        if TextValue = '' then
            exit(0);

        if Evaluate(DecimalVar, TextValue) then
            exit(DecimalVar)
        else
            exit(0);
    end;

    var
        methodOCR: Enum "Method OCR API";
}
