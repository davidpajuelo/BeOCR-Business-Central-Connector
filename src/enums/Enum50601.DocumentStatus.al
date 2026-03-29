enum 50601 "Document Status"
{
    Extensible = true;
    value(0; "Pending")
    {
        Caption = 'Pending', Comment = 'ESP="Pendiente"';
    }
    value(1; "Send")
    {
        Caption = 'Send', Comment = 'ESP="Enviado"';
    }
    value(2; "Download")
    {
        Caption = 'Download', Comment = 'ESP="Descargado"';
    }
    value(3; "Process")
    {
        Caption = 'Process', Comment = 'ESP="Procesado"';
    }
}
