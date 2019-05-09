pragma solidity 0.5.8;

contract MichelTelo {
    
    address payable public michelTelo;
    address payable public advogado;
    address public produtora;
    uint public valorDoContrato;
    uint public dataDePagamento;
    uint public indiceMulta;
    uint public percentualMichelTelo;
    uint public percentualAdvogado;
    
    
    bool public pago;
    
    bool public retirado;
    
    event pagamentoRealizado (uint valor);
    
    modifier autorizadosRecebimento () {
        require (msg.sender == michelTelo || msg.sender == advogado, "Operaçao exclusiva do contratado.");
        _;    
    }
    
    modifier autorizadoPagamento () {
        require (msg.sender == produtora, "Operaçao exclusiva do contratante.");
        _;
    }
    
    constructor(
        address payable _michelTelo,
        address payable _advogado,
        address _produtora,
        uint _valorDoContrato,
        uint _dataDePagamento,
        uint _percentualMichelTelo,
        uint _percentualAdvogado
    ) public {
        michelTelo = _michelTelo;
        advogado = _advogado;
        produtora = _produtora;
        valorDoContrato = _valorDoContrato;
        dataDePagamento = _dataDePagamento;
        percentualMichelTelo = _percentualMichelTelo;
        percentualAdvogado = _percentualAdvogado;
        indiceMulta = 5;
    }
    
    function saldo () public view returns (uint) {
        return address(this).balance;
    }
    
    
    
    function simulacaoMulta (uint dataDePagamentoSimulado) public view returns (uint valorSimuladoMulta) {
        valorSimuladoMulta = valorDoContrato*((indiceMulta / 100)*((dataDePagamentoSimulado - dataDePagamento) / 86400));
        return valorSimuladoMulta;
    }
    
    function calculoMulta () public view returns (uint valorMulta) {
        valorMulta = valorDoContrato*((indiceMulta / 100)*((now - dataDePagamento) / 86400));
        return valorMulta;
    }
    
    function pagamentoNoPrazo () public payable autorizadoPagamento {
        require (
            now <= dataDePagamento, "Devedor em mora.");
        require (
            msg.value == valorDoContrato, "Valor diverso do devido");
       
        pago = true;
        
        emit pagamentoRealizado(msg.value);
    }
    
    function pagamentoEmMora() public payable autorizadoPagamento {
        require (
            now > dataDePagamento, "Mora não constituida.");
        require (
            pago == false, "Pagamento já realizado.");
        require (
            msg.value == valorDoContrato*((indiceMulta / 100)*((now - dataDePagamento) / 86400)) + valorDoContrato, "Valor diverso do devido.");
        
        pago = true;
        
        emit pagamentoRealizado(msg.value);
    }
    
     function distribuicaoDeValores() public autorizadosRecebimento {
        require(
            pago == true, "Pagamento não realizado");
        require(
            retirado == false, "Distribuição já realizada.");
             
        michelTelo.transfer((percentualMichelTelo / 100) * address(this).balance);
        advogado.transfer((percentualAdvogado / 100) * address(this).balance);
        
        retirado = true;
    }
    
    
}
