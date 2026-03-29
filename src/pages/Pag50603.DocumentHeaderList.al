page 50603 "Document Header List"
{
    Caption = 'BeOCR - Document Headers', Comment = 'ESP="BeOCR - Lista de documentos"';
    PageType = List;
    SourceTable = "Document Header";
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;
    //ModifyAllowed = false;
    //DeleteAllowed = false;
    CardPageId = "Document Header Card";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = all;
                }
                field("ID API"; Rec."ID API")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of OCR API.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number.';
                }
                field("Invoice Date"; Rec."Invoice Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoice date.';
                }
                field(NIF; Rec.NIF)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the NIF (Tax Identification Number).';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor or customer name.';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT amount.';
                }
                field(Total; Rec.Total)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount.';
                }
            }
        }
    }
    actions
    {
        Area(Processing)
        {
            action("Upload Document")
            {
                ApplicationArea = All;
                Caption = 'Upload Document BeOCR', Comment = 'ESP="Cargar Documento BeOCR"';
                Image = Import;
                ToolTip = 'Upload a PDF document to process with BeOCR.', Comment = 'ESP="Cargue un documento para procesar con BeOCR."';

                trigger OnAction()
                begin
                    Rec.UploadDocument();
                    CurrPage.Update();
                end;
            }
            action(SyncBeOCR)
            {
                Caption = 'Sync BeOCR', Comment = 'ESP="Sincronizar BeOCR"';
                Image = MoveDown;
                trigger OnAction()
                var
                    SyncronizeBeOCR: Codeunit "Syncronice Be OCR";
                begin
                    SyncronizeBeOCR.UpgradeLogOCR();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Promoted_UploadDocument; "Upload Document") { }
                actionref(Promoted_SyncBeOCR; SyncBeOCR) { }
            }
        }
    }

}
