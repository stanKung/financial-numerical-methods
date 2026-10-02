function run_checks(selected)
base=fileparts(fileparts(mfilename('fullpath')));
root=fullfile(base,'coursework');
audit=fullfile(base,'results');
set(groot,'defaultFigureVisible','off'); diary(fullfile(audit,'checks.log'));
fprintf('MATLAB %s\n',version);
records=struct('case',{},'passed',{},'detail',{});
cases={'HW1','HW2_1','HW2_2','HW3_1','HW3_2','HW3_3','HW4_1','HW4_2','HW4_3','HW5_1','HW5_2','HW6_1','HW6_2','HW6_3','HW7_1','HW7_2','HW8','HW9','HW10','HW11','HW12','HW13'};
if nargin>0
    previous=jsondecode(fileread(fullfile(audit,'checks.json')));
    cases=selected;
end
for k=1:numel(cases)
    c=cases{k}; fprintf('\n=== %s ===\n',c);
    try
        detail=check_case(root,c);
        records(end+1)=struct('case',c,'passed',true,'detail',detail);
        fprintf('PASS: %s\n',detail);
    catch ME
        records(end+1)=struct('case',c,'passed',false,'detail',getReport(ME,'extended','hyperlinks','off'));
        fprintf('FAIL: %s\n',records(end).detail);
    end
    close all;
end
checks=struct('file',{},'messages',{},'dependencies',{},'products',{});
if nargin>0
    merged=previous.tests;
    for k=1:numel(records)
        ix=find(strcmp({merged.case},records(k).case)); merged(ix)=records(k);
    end
    records=merged;
end
files=dir(fullfile(root,'**','*.m'));
for k=1:numel(files)
    f=fullfile(files(k).folder,files(k).name);
    [deps,products]=matlab.codetools.requiredFilesAndProducts(f);
    deps=cellfun(@(p)strrep(p,[base,filesep],''),deps,'UniformOutput',false);
    relativeFile=strrep(f,[base,filesep],'');
    checks(end+1)=struct('file',relativeFile,'messages',checkcode(f,'-id'),'dependencies',{deps},'products',{products});
end
fid=fopen(fullfile(audit,'checks.json'),'w','n','UTF-8');
fprintf(fid,'%s',jsonencode(struct('version',version,'tests',records,'static',checks),'PrettyPrint',true)); fclose(fid);
fprintf('\nTOTAL: %d/%d passed\n',sum([records.passed]),numel(records)); diary off;
assert(all([records.passed]),'Some checks failed; see results/checks.json.');
end
function f=loc(root,n,name,q)
f=fullfile(root,sprintf('HW%d_112705018',n));
if nargin==4, f=fullfile(f,sprintf('HW%d_112705018_%d',n,q)); end
f=fullfile(f,name);
end
function s=execute(file)
run(file); names=who; s=struct;
for ix=1:numel(names)
    if ~strcmp(names{ix},'file'), s.(names{ix})=eval(names{ix}); end
end
end
function detail=check_case(root,c)
switch c
case 'HW1'
assert(fix(1/3+1/3+1/3)==1 && fix(1/7+1/7+1/7+1/7+1/7+1/7+1/7)==0);
assert(isnan(0.1^10000*0.1^-10000) && exp(10000*log(0.1)-10000*log(0.1))==1);
detail='PDF outputs reproduced: 1, 0, NaN, 1.';
case 'HW2_1'
execute(loc(root,2,'HW2_112705018_1.m',1));
assert(isequal(readmatrix(loc(root,2,'b.xls',1)),[2 3 4;3 4 5;5 6 7]));
assert(isequaln(readmatrix(loc(root,2,'c.xls',1),'Range','A1:D103'),readmatrix(loc(root,2,'Read.xls',1),'Range','A1:D103')));
detail='b.xls and c.xls match matrices; explicit A1:D103 preserves leading blank rows.';
case 'HW2_2'
s=execute(loc(root,2,'HW2_112705018_2.m',2)); A=readmatrix(loc(root,2,'Read.xls',2)); A=A(3:end,2:4);
assert(isequal(s.max_matrix,max(A)) && isequal(s.min_matrix,min(A)) && isequal(s.mean_matrix,mean(A)) && isequal(s.sum_matrix,sum(A)));
W=load(loc(root,2,'workspace.mat',2)); assert(isequal(W.sum_matrix,sum(A)));
detail='All 12 statistics and regenerated workspace.mat checked.';
case 'HW3_1'
s=execute(loc(root,3,'HW3_112705018_1.m',1));
assert(isequal(s.a,[56.3 51.1 30;56.5 51.5 29.85]) && isequal(readmatrix(loc(root,3,'a.xls',1)),s.a));
detail='Selected 2x3 matrix and a.xls verified.';
case 'HW3_2'
execute(loc(root,3,'HW3_112705018_2.m',2)); t=readmatrix(loc(root,3,'Read_InterestRate.xlsx',2)); t=t(:,2:end);
expected=[1+t(1,1)/12,1+t(2,1)/12,1+t(1,2)/4,1+t(1,3)/2,(1+t(1,5)/2)^2,t(1,:)-t(2,:)];
result=readmatrix(loc(root,3,'HW3_112705018_result.xlsx',2));
assert(isequal(size(result),[1,12]) && max(abs(result-expected))<1e-12);
detail='All 12 Excel cells A1:L1 verified.';
case 'HW3_3'
s=execute(loc(root,3,'HW3_112705018_3.m',3)); assert(abs(s.A-1)<1e-12 && abs(s.b-3)<1e-12);
detail='Affine least squares A=1, b=3.';
case 'HW4_1'
s=execute(loc(root,4,'HW4_112705018_1.m',1)); X=[s.X2300,s.X2800];
assert(norm(X'*(s.Y9999-X*s.C))<1e-4 && norm(s.C-s.x)<1e-8);
detail=sprintf('OLS/regress agree: %.8f, %.8f.',s.C);
case 'HW4_2'
s=execute(loc(root,4,'HW4_112705018_2.m',2)); residual=s.Y9999(s.test_size)-s.Z;
assert(norm(s.C-s.x)<1e-8 && isempty(intersect(s.train_size,s.test_size)));
assert(isequal(s.short_entry_time,find(residual>2*s.threshold)+50) && isequal(s.long_entry_time,find(residual< -2*s.threshold)+50));
detail=sprintf('%d long, %d short entry signals; cost assumptions retained.',numel(s.long_entry_time),numel(s.short_entry_time));
case 'HW4_3'
s=execute(loc(root,4,'HW4_112705018_3.m',3)); A=readmatrix(loc(root,4,'Read.xls',3)); A=A(3:end,2:4);
assert(isequal(s.filtered_data,A(A(:,1)>5000 & A(:,2)>260,:)));
detail=sprintf('%d qualifying rows verified.',size(s.filtered_data,1));
case 'HW5_1'
s=execute(loc(root,5,'HW5_112705018_1.m',1)); assert(isequal(double(s.A),33:2:125)); detail='47 odd ASCII codes verified.';
case 'HW5_2'
s=execute(loc(root,5,'HW5_112705018_2.m',2));
assert(all(s.Result{:,1}>5000 & s.Result{:,1}<5500) && isequal(s.idx,find(s.Data{:,2}>5000 & s.Data{:,2}<5500)));
A=readmatrix(loc(root,5,'Read.xls',2)); A=A(3:end,2:4);
assert(isequal(s.Result{:,:},A(A(:,1)>5000 & A(:,1)<5500,:)));
detail=sprintf('%d filtered rows and idx verified.',numel(s.idx));
case 'HW6_1'
d=fileparts(loc(root,6,'Price_cal.m',1)); addpath(d); cleanup=onCleanup(@()rmpath(d));
p=Price_cal(90,.03); assert(abs(p-(100000-100000*.03*90/365))<1e-10); detail=sprintf('90-day note price %.8f.',p);
case 'HW6_2'
d=fileparts(loc(root,6,'BS_put_parity.m',2)); addpath(d); cleanup=onCleanup(@()rmpath(d));
for T=[0,1], for v=[0,.2]
    [call,put,pp,ok]=BS_put_parity(100,105,.03,T,v); assert(ok && abs(put-pp)<1e-10);
    if T>0 && v>0, [c0,p0]=blsprice(100,105,.03,T,v); assert(max(abs([call-c0,put-p0]))<1e-10); end
end,end
detail='blsprice/parity, expiry and zero-volatility verified.';
case 'HW6_3'
d=fileparts(loc(root,6,'Merton.m',3)); addpath(d); cleanup=onCleanup(@()rmpath(d));
for V=[50,100,200]
    [E,D,TB,BC]=Merton(V,80,1,.05,.2,.04,.2,.3); assert(abs(E+D-V-TB+BC)<1e-9 && all([E,D,TB,BC]>=0));
end
detail='Merton identity/nonnegative values verified at V=50,100,200.';
case 'HW7_1'
d=fileparts(loc(root,7,'MacaulayDuration.m',1)); addpath(d); cleanup=onCleanup(@()rmpath(d));
[P,~,MD]=MacaulayDuration(.05,5,0,100); assert(abs(MD-5)<1e-12 && abs(P-100/1.05^5)<1e-10);
[P,~,MD]=MacaulayDuration(.05,5,.04,100); h=1e-6;
[p1,~,~]=MacaulayDuration(.05+h,5,.04,100); [p2,~,~]=MacaulayDuration(.05-h,5,.04,100);
assert(abs(MD+(1.05/P)*(p1-p2)/(2*h))<1e-7); detail=sprintf('Zero-coupon and derivative checks; MD=%.8f.',MD);
case 'HW7_2'
d=fileparts(loc(root,7,'Yield.m',2)); addpath(d); cleanup=onCleanup(@()rmpath(d));
target=sum([repmat(2,1,9),102]./1.025.^(1:10)); [p,y]=Yield(100,.04,5,10,0,.2,target);
assert(abs(p-target)<=.001 && abs(y-.05)<1e-5);
assert_error(@()Yield(100,.04,5,10,.1,.2,target),'Yield:Unbracketed');
detail=sprintf('Recovered yield %.8f; invalid bracket rejected.',y);
case 'HW8'
d=fileparts(loc(root,8,'implied_vol.m')); addpath(d); cleanup=onCleanup(@()rmpath(d));
[c0,p0]=blsprice(100,105,.03,1,.24);
[vc,~]=implied_vol(100,105,.03,1,0,1,c0,'call'); [vp,~]=implied_vol(100,105,.03,1,0,1,p0,'put');
assert(max(abs([vc,vp]-.24))<1e-5);
assert_error(@()implied_vol(100,105,.03,1,0,.1,c0,'call'),'implied_vol:Unbracketed');
detail=sprintf('Recovered 24%% IV: call %.8f, put %.8f.',vc,vp);
case 'HW9'
s=execute(loc(root,9,'HW9_112705018.m')); assert(abs(s.PC_parity)<1e-10 && abs(s.TheoryResidual)<4*s.ParityStdError);
detail=sprintf('Pathwise parity passed; theoretical residual %.8f, SE %.8f.',s.TheoryResidual,s.ParityStdError);
case 'HW10'
cache=fullfile(fileparts(root),'results','hw10_asian.mat');
if isfile(cache),s=load(cache);else,s=execute(loc(root,10,'HW10_112705018.m'));end
assert(all(isfinite(s.ResultsRandomMC),'all') && all(isfinite(s.ResultsQMC_CV),'all'));
assert(size(s.ResultsRandomMC,2)==197);
rng(921,'twister'); N=100000; dt=s.T/s.Step;
lp=log(s.S0)+[zeros(N,1),cumsum((s.r-s.vol^2/2)*dt+s.vol*sqrt(dt)*randn(N,s.Step),2)];
ap=exp(-s.r*s.T)*max(s.K-mean(exp(lp),2),0); gp=exp(-s.r*s.T)*max(s.K-exp(mean(lp,2)),0);
assert(abs(mean(gp)-s.Price_G_Analytical)<4*std(gp)/sqrt(N)); last=s.ResultsQMC_CV(:,end);
assert(abs(last(1)-mean(ap))<4*std(ap)/sqrt(N)+(last(3)-last(2)));
detail=sprintf('197 sample sizes; QMC %.8f; independent 100k MC %.8f (SE %.8f); geometric benchmark passed.',last(1),mean(ap),std(ap)/sqrt(N));
case 'HW11'
d=fileparts(loc(root,11,'Heston_Leastsquare.m')); addpath(d); cleanup=onCleanup(@()rmpath(d));
p=Heston_Leastsquare(2,.04,.04,.2,.03,100,100,-.5,12000,50,1,'p');
deep=Heston_Leastsquare(2,.04,.04,.2,.03,50,100,-.5,2000,25,1,'p');
call=Heston_Leastsquare(2,.04,.04,0,.03,100,100,0,20000,50,1,'c'); [bc,~]=blsprice(100,100,.03,1,.2);
assert(isfinite(p) && p>=0 && p<=100 && deep>=50 && abs(call-bc)<.6);
detail=sprintf('Put %.8f; immediate exercise verified; constant-variance call %.8f vs BS %.8f; foreign rate=0 assumption.',p,call,bc);
case 'HW12'
s=execute(loc(root,12,'HW12_112705018.m'));
assert(size(s.SD,1)==16 && size(s.S_forecast,1)==14 && norm(s.a-mean(s.S_forecast(2:end,:),1))<1e-10);
assert(abs(s.SimuStdError-std(s.payoff)*exp(-s.r*s.dT)/sqrt(s.SimuPath))<1e-10);
rng(730,'twister'); N=40000; spots=repmat(s.SD(end,:),N,1); accum=zeros(N,3);
for day=1:13
    z=randn(N,3)*s.B'; spots=spots.*exp((s.r-.5*s.Vol.^2)*s.dt+sqrt(s.dt)*s.Vol.*z); accum=accum+spots;
end
val=exp(-s.r*s.dT)*max(min(accum/13,[],2)-s.K,0);
assert(abs(mean(val)-s.CallPrice)<4*sqrt(s.SimuStdError^2+var(val)/N));
detail=sprintf('Dates %s to %s; price %.8f, SE %.8f; independent MC %.8f.',string(s.Date(1)),string(s.Date(end)),s.CallPrice,s.SimuStdError,mean(val));
case 'HW13'
s=execute(loc(root,13,'HW13_112705018.m')); assert(abs(s.knockinCallPrice+s.knockoutCallPrice-s.vanillaCallPrice)<1e-10);
n=50; dt=2/n; u=exp(.3*sqrt(dt)); d=1/u; p=(exp(.1*dt)-d)/(u-d);
prices=100*u.^(n:-1:0).*d.^(0:n); v=max(prices-110,0); o=v.*(prices>90);
for t=n-1:-1:0
    v=exp(-.1*dt)*(p*v(1:end-1)+(1-p)*v(2:end)); o=exp(-.1*dt)*(p*o(1:end-1)+(1-p)*o(2:end));
    prices=100*u.^(t:-1:0).*d.^(0:t); o(prices<=90)=0;
end
assert(abs(v-s.vanillaCallPrice)<1e-9 && abs(o-s.knockoutCallPrice)<1e-9);
detail=sprintf('Independent CRR/parity: vanilla %.8f, out %.8f, in %.8f.',v,o,s.knockinCallPrice);
end
end
function assert_error(f,id)
try, f(); catch ME, assert(strcmp(ME.identifier,id)); return; end
error('Expected error not raised: %s',id);
end
