codeunit 50602 "Syncronice Be OCR"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        UpgradeLogOCR();
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
        ResponseText := ResponseText.Replace('\n', '  ');
        // Parse JSON array
        if not JsonArray.ReadFrom(ResponseText) then
            Error('Invalid JSON format in response from getDocumentsOCR.');
        // Process each document in the array
        for i := 0 to JsonArray.Count - 1 do begin
            JsonObject := JsonArray.GetObject(i);
            // Get the ID API from the documen
            JsonObject.Get('id', JsonToken);
            IdAPI := Format(JsonToken);
            OcrJson := JsonObject.GetText('ocr_json');
            // Check if DocumentLedgerEntry exists with this ID API and is not Downloaded
            base64Text := JsonObject.GetText('image_base64-1');
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
            if DocumentHeader.insertDocument(IdAPI, OcrJson, base64Text) then
                ORCLog.InsertError(idAPI, GetLastErrorText());

        end;
    end;

}
