page 50607 "BeOCR Log List"
{
    ApplicationArea = All;
    Caption = 'BeOCR - Log List';
    PageType = List;
    SourceTable = "OCR Log";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID field.', Comment = '%';
                }
                field("ID API"; Rec."ID API")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID API field.', Comment = '%';
                }
                field(Error; Rec.Error)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error field.', Comment = '%';
                }
            }
        }
    }
}
