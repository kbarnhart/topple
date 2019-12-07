function space = icewedgespacing(nwedge)
load wedgespacing
spacing=[wedgespacing.c];% wedgespacing.a];
iceind=ceil(numel(spacing)*rand(1,nwedge));
space=spacing(iceind);

end