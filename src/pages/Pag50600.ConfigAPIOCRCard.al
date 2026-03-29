page 50600 "BeOCR Config Card"
{
    Caption = 'BeOCR - Config Card', Comment = 'ESP="BeOCR - Configuración"';
    PageType = Card;
    SourceTable = "BeOCR Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group("General")
            {
                Caption = 'General';


                field(URL; Rec.URL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL of the API BeOCR.', Comment = 'ESP="Especifica la URL de la API de BeOCR."';
                }

                field(Token; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the authentication token.', Comment = 'ESP="Accede a https://beocr.com/ registrate y crea un token, añade aquí el token."';
                    ExtendedDatatype = Masked;
                }
                field(DocumentHeaderSerie; Rec."Document Header Serie")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Document Header Serie.', Comment = 'ESP="Especifica el Nº Serie de Documentos OCR."';
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Update Token")
            {
                ApplicationArea = All;
                Caption = 'Update Token';
                Image = RefreshLines;
                ToolTip = 'Refresh the authentication token.';

                trigger OnAction()
                begin
                    // TODO: Implement token update logic
                    Message('Token update functionality to be implemented.');
                end;
            }
            action("Document Headers")
            {
                ApplicationArea = All;
                Caption = 'Document Headers';
                Image = Document;
                ToolTip = 'View the document headers extracted by the OCR API.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Document Header List");
                end;
            }
        }
    }
}
