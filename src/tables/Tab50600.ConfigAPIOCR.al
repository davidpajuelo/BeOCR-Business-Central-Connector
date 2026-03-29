table 50600 "BeOCR Setup"
{
    Caption = 'BeOCR Setup', Comment = 'ESP="Configuración BeOCR"';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; ID; Code[10])
        {
            Caption = 'ID', Comment = 'ESP="ID"';
            DataClassification = SystemMetadata;
        }
        field(2; URL; Text[100])
        {
            Caption = 'URL', Comment = 'ESP="URL"';
            DataClassification = SystemMetadata;
            InitValue = 'https://beocr.com/api';
        }

        field(3; "API Key"; Text[100])
        {
            Caption = 'API Key', Comment = 'ESP="API Key"';
            DataClassification = SystemMetadata;
        }
        field(4; "Document Header Serie"; Code[10])
        {
            Caption = 'Document Header Serie', Comment = 'ESP="Nº Serie de Documentos OCR"';
            TableRelation = "No. Series";
            DataClassification = SystemMetadata;
        }

    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
