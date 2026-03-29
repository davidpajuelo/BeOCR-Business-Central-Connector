table 50604 "OCR Log"
{
    Caption = 'OCR Log';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "ID API"; Text[60])
        {
            Caption = 'ID API';
        }
        field(3; Error; Text[2000])
        {
            Caption = 'Error';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
    procedure InsertError(idAPI: Text[60]; Error: Text)
    var
        OCRLog: Record "OCR Log";
    begin
        rec.Init();
        OCRLog.Reset();
        if OCRLog.FindLast() then
            Rec.ID := OCRLog.id + 1;
        rec."ID API" := idAPI;
        rec.Error := copystr(Error, 1, 2000);
        rec.insert();
    end;
}
