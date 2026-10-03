page 50604 "Document Header Card"
{
    Caption = 'BeOCR - Document Header Card', Comment = 'ESP="Be OCR - Ficha de documentos"';
    PageType = Card;
    SourceTable = "Document Header";

    layout
    {
        area(Content)
        {
            group("General")
            {
                Caption = 'General', Comment = 'ESP="General"';
                grid(Grid1)
                {
                    ShowCaption = false;
                    group(Control)
                    {
                        Caption = 'Modify Data', Comment = 'ESP="Modificar Datos"';
                        field("ID API"; Rec."ID API")
                        {
                            ApplicationArea = All;
                            Caption = 'ID API', Comment = 'ESP="ID API"';
                            ToolTip = 'Specifies the ID of OCR API.';
                            Editable = false;
                        }
                        field("No."; Rec."No.")
                        {
                            ApplicationArea = All;
                            Caption = 'No.', Comment = 'ESP="Nº"';
                            ToolTip = 'Specifies the document number.';

                        }
                        field("Invoice Date"; Rec."Invoice Date")
                        {
                            ApplicationArea = All;
                            Caption = 'Invoice Date', Comment = 'ESP="Fecha Factura"';
                            ToolTip = 'Specifies the invoice date.';

                        }

                        field(NIF; Rec.NIF)
                        {
                            ApplicationArea = All;
                            Caption = 'NIF', Comment = 'ESP="NIF"';
                            ToolTip = 'Specifies the NIF (Tax Identification Number).';
                        }
                        field(Name; Rec.Name)
                        {
                            ApplicationArea = All;
                            Caption = 'Name', Comment = 'ESP="Nombre"';
                            ToolTip = 'Specifies the vendor or customer name.';
                        }
                        field("Vendor No."; REc."Vendor No.")
                        {
                            ApplicationArea = all;
                            Caption = 'Vendor No.', Comment = 'ESP="Nº de Proveedor"';
                            TableRelation = Vendor;
                            ShowMandatory = true;
                        }
                        field("VAT Amount"; Rec."VAT Amount")
                        {
                            ApplicationArea = All;
                            Caption = 'VAT Amount', Comment = 'ESP="Importe IVA"';
                            ToolTip = 'Specifies the VAT amount.';
                        }
                        field(Total; Rec.Total)
                        {
                            ApplicationArea = All;
                            Caption = 'Total', Comment = 'ESP="Total"';
                            ToolTip = 'Specifies the total amount.';
                        }
                    }
                }


            }

            part("Document Lines"; "Document Line SubList")
            {
                ApplicationArea = All;
                Caption = 'Document Lines';
                SubPageLink = ID = FIELD(ID);
            }
        }
        area(factboxes)
        {
            part(PDFPreview; "PDF Preview")
            {
                ApplicationArea = all;
                SubPageLink = "ID API" = field("ID API");
            }
        }

    }
    actions
    {


        area(Processing)
        {


            action(ConvertToPurchaseInvoice)
            {
                Caption = 'Convertir a Factura de Compra';
                ToolTip = 'Convierte el documento OCR en un Factura de compra';
                ApplicationArea = All;
                Image = NewOrder;
                trigger OnAction()
                var
                    OCRIntegration: Codeunit "OCR Integration";
                    PurchaseHeader: Record "Purchase Header";
                    PurchaseInvoice: Page "Purchase Invoice";
                    PurchaseOrderNo: Code[20];
                begin
                    PurchaseOrderNo := OCRIntegration.ConvertDocumentToPurchase(Rec.ID, enum::"Purchase Document Type"::Invoice);
                    OCRIntegration.OpenDocumentCardPurchase(PurchaseOrderNo, enum::"Purchase Document Type"::Invoice);
                end;
            }
            action(ConvertToPurchaseOrder)
            {
                Caption = 'Convertir a Pedido de Compra';
                ToolTip = 'Convierte el documento OCR en un Pedido de compra';
                ApplicationArea = All;
                Image = NewOrder;
                trigger OnAction()
                var
                    OCRIntegration: Codeunit "OCR Integration";
                    PurchaseHeader: Record "Purchase Header";
                    PurchaseInvoice: Page "Purchase Invoice";
                    PurchaseOrderNo: Code[20];
                begin
                    PurchaseOrderNo := OCRIntegration.ConvertDocumentToPurchase(Rec.ID, enum::"Purchase Document Type"::Order);
                    OCRIntegration.OpenDocumentCardPurchase(PurchaseOrderNo, enum::"Purchase Document Type"::Order);
                end;
            }
        }
        area(Navigation)
        {
            action("Open Invoices")
            {
                ApplicationArea = All;
                Caption = 'Open Invoices', Comment = 'ESP="Abrir facturas"';
                trigger OnAction()
                var
                    OCRIntegration: Codeunit "OCR Integration";
                begin
                    OCRIntegration.OpenDocumentListPurchase(Rec."No.", enum::"Purchase Document Type"::Invoice);
                end;
            }
            action("Open Orders")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    OCRIntegration: Codeunit "OCR Integration";
                begin
                    OCRIntegration.OpenDocumentListPurchase(Rec."No.", enum::"Purchase Document Type"::Order);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {

                actionref(Promoted_ConverToPurchaseInvoice; ConvertToPurchaseInvoice) { }
                actionref(Promoted_ConverToPurchaseOrder; ConvertToPurchaseOrder) { }
            }
        }
    }



    var
        tempDocumentHeader: Record "Document Header" temporary;
        VendorNo: Code[20];
        noStyle: text;
        invoiceDateStyle: text;
        nameStyle: text;
        vatAmountStyle: text;
        totalStyle: text;
        nifStyle: text;

        vendorNoStyle: Text;
        isModify: Boolean;
}
