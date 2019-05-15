pragma solidity 0.5.8;

contract FreteAviao {
    
    uint public limiteAviao;
    uint public valorPassagem;
    uint public dataEncerramentoVendas;
    address payable public carteiraCompanhiaAerea;
    struct passagem {string nomePassageiro; address payable carteiraCliente; address payable carteiraAgencia; bool estornoParaAgencia;}
    passagem[] public passageiros;
    mapping(address => passagem) public passageirosPorAgencia;
    mapping(string => passagem) public mapeamentoReservaPorNome;
    
    event reservaEfetuada (string aviso, string nomePassageiro, address carteiraAgencia);
    event pousoEfetuadoComSucesso (string aviso, string nnomePassageiro, address carteiraAgencia);
    
    
    modifier somenteCompanhiaAerea(){
        require (msg.sender == carteiraCompanhiaAerea, "Função exclusiva da Companhia Aérea.");
    _;}
    
   
    constructor (
        uint _limiteAviao,  
        uint _valorPassagem,
        uint _dataEncerramentoVendas,
        address payable _carteiraCompanhiaAerea
        ) public {
        limiteAviao = _limiteAviao;
        valorPassagem = _valorPassagem;
        dataEncerramentoVendas = _dataEncerramentoVendas;
        carteiraCompanhiaAerea = _carteiraCompanhiaAerea;
        }
        
    function reserva (string memory nomePassageiro, address payable carteiraCliente, bool estornoParaAgencia) public payable {
        require (now < dataEncerramentoVendas, "Período de compras encerrado.");
        require (msg.value == valorPassagem, "Incorreto o valor da passagem.");
        require (passageiros.length < limiteAviao, "Não há passagens disponíveis.");
        
        address payable carteiraAgencia = msg.sender;
        
        passagem memory passagemReservada = passagem (nomePassageiro, carteiraCliente, carteiraAgencia, estornoParaAgencia);
        passageiros.push(passagemReservada);
        passageirosPorAgencia[carteiraAgencia] = passagemReservada;
        
        emit reservaEfetuada ("Reserva efetuada com sucesso.", nomePassageiro, carteiraAgencia);
    } 
        
    function pousoSeguro () somenteCompanhiaAerea public {
        require (now > dataEncerramentoVendas, "Vôo ainda não saiu.");
        
        for (uint i=0; i < passageiros.length; i++){
           string memory passageiroQueChegou = passageiros[i].nomePassageiro;
           address carteiraDaAgenciaQueChegou = passageiros[i].carteiraAgencia;
            emit pousoEfetuadoComSucesso ("Pouso realizado com sucesso.", passageiroQueChegou, carteiraDaAgenciaQueChegou);
            
        }
        
        carteiraCompanhiaAerea.transfer(address(this).balance);
        
        
    }
    
    function estornoDeTodos () somenteCompanhiaAerea public {
        
        for (uint i=0; i < passageiros.length; i++){
            if (passageiros[i].estornoParaAgencia) {
                address payable carteiraDeEstorno = passageiros[i].carteiraAgencia;
               carteiraDeEstorno.transfer(valorPassagem);
            }
            
            else {
                address payable carteiraDeEstorno = passageiros[i].carteiraCliente;
                carteiraDeEstorno.transfer(valorPassagem);
            }    
        }
        
    }
   
   function estornoIndividual (string memory nomeClienteEstorno) somenteCompanhiaAerea public {
       for (uint i=0; i < passageiros.length; i++){
            if (keccak256(nomeClienteEstorno) == keccak256(passageiros[i].nomePassageiro)) {
                if (passageiros[i].estornoParaAgencia) {
                address payable carteiraDeEstorno = passageiros[i].carteiraAgencia;
               carteiraDeEstorno.transfer(valorPassagem);
                }
            }    
            
                else {
                address payable carteiraDeEstorno = passageiros[i].carteiraCliente;
                carteiraDeEstorno.transfer(valorPassagem);
                }    
            }
            
       
       
       
   }  
}
