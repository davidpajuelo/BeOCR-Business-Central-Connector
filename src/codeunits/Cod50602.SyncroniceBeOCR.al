codeunit 50602 "Syncronice Be OCR"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        DocumentHeader: record "Document Header";
        OCRIntegration: Codeunit "OCR Integration";
        IdList: List of [Integer];
        i: Integer;
        LogId: Integer;
        LogJsonObject: JsonObject;
        OcrJson: Text;
        base64Text: text;
    begin

        OCRIntegration.SetMethod(Enum::"Method OCR API"::logocr_ids);
        IdList := OCRIntegration.GetLogocrIds();

        // Iterar sobre cada ID y descargar la información
        for i := 1 to IdList.Count do begin
            LogId := IdList.Get(i);
            DocumentHeader.Reset();
            DocumentHeader.SetRange("ID API", format(LogId));
            if not DocumentHeader.findfirst() then begin

                // Cambiar el método a ocr_logs_by_id para descargar cada log
                OCRIntegration.SetMethod(Enum::"Method OCR API"::ocr_logs_by_id);

                // Llamar al método GetOCRLogById para obtener los datos del log
                LogJsonObject := OCRIntegration.GetOCRLogById(LogId);
                if LogJsonObject.Contains('ocr_json') then
                    OcrJson := LogJsonObject.GetText('ocr_json');
                // Check if DocumentLedgerEntry exists with this ID API and is not Downloaded
                if LogJsonObject.Contains('image_base64-1') then
                    base64Text := LogJsonObject.GetText('image_base64-1');
                if not ((OcrJson = '') or (base64Text = '')) then
                    InsertDocument(format(LogId), OcrJson, base64Text);
            end;

        end;

    end;



    procedure UpgradeLogOCR()
    var
        OCRIntegration: Codeunit "OCR Integration";
        DocumentHeader: Record "Document Header";
        DocumentLine: Record "Document Line";
        ResponseText: Text;
        base64Text: Text;
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        i: Integer;
        IdAPI: Text;
        OcrJson: Text;
    begin
        OCRIntegration.SetMethod(Enum::"Method OCR API"::ocr_logs);
        ResponseText := OCRIntegration.getDocumentsOCR();
        // Parse the response - it should be a JSON array
        if ResponseText = '' then
            exit;
        //ResponseText := DelChr(ResponseText, '<>', '"');
        // Limpiar el JSON: remover \n y cambiar \" a "
        //ResponseText := ResponseText.Replace('\n', '').Replace('\"', '"');
        // Parse JSON array
        if not JsonArray.ReadFrom(ResponseText) then
            Error('Invalid JSON format in response from getDocumentsOCR. %1', ResponseText);
        // Process each document in the array
        for i := 0 to JsonArray.Count - 1 do begin
            JsonObject := JsonArray.GetObject(i);
            // Get the ID API from the documen
            JsonObject.Get('id', JsonToken);
            IdAPI := Format(JsonToken);
            clear(OcrJson);
            clear(base64Text);
            if JsonObject.Contains('ocr_json') then
                OcrJson := JsonObject.GetText('ocr_json');
            // Check if DocumentLedgerEntry exists with this ID API and is not Downloaded
            if JsonObject.Contains('image_base64-' + format(1)) then
                base64Text := JsonObject.GetText('image_base64-' + format(1));
            if not ((OcrJson = '') or (base64Text = '')) then
                InsertDocument(IdAPI, OcrJson, base64Text);
        end;
    end;

    local procedure InsertDocument(idAPI: text; OcrJson: text; base64Text: Text)
    var
        DocumentHeader: Record "Document Header";
        ORCLog: Record "OCR Log";
    begin
        // Check if DocumentHeader already exists for this ID API
        DocumentHeader.Reset();
        DocumentHeader.SetRange("ID API", IdAPI);

        if not DocumentHeader.Get(IdAPI) then begin
            // Insert the document header and lines using the ocr_json
            ClearLastError();
            if not DocumentHeader.insertDocument(IdAPI, OcrJson, base64Text) then
                ORCLog.InsertError(idAPI, GetLastErrorText());

        end;
    end;

    local procedure ProcessOCRLogJson(LogJsonObject: JsonObject)
    var
        JsonToken: JsonToken;
        IdAPI: Text;
        OcrJson: Text;
        base64Text: Text;
    begin
        // Extraer los campos del JSON descargado
        if LogJsonObject.Get('id', JsonToken) then
            IdAPI := JsonToken.AsValue().AsText();

        if LogJsonObject.Get('ocr_json', JsonToken) then
            OcrJson := JsonToken.AsValue().AsText();

        if LogJsonObject.Get('image_base64', JsonToken) then
            base64Text := JsonToken.AsValue().AsText();

        // Llamar a InsertDocument con los datos extraídos
        if IdAPI <> '' then
            InsertDocument(IdAPI, OcrJson, base64Text);
    end;

}
