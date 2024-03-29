library(fpp2)
library(ggplot2)
data("departures")
x=departures[,1]
x%,%autoplot()+theme_bw()+xlab("Years")+ ylab("Departures")
library(forecast)
m0<-auto.arima(x)
m0
library(latex2exp)
x%,%diff(12)%,%diff(1)%,%autoplot()+theme_bw()+ylab(TeX("$(1-B)(1-B^2)X_t$}$"))+xlab("")
library(urca)
t1=x%,%diff(12)%,%diff(1)%,%ur.df(lags = 6,type="none")
summary(t1)
library(urca)
t2=x%,%diff(12)%,%diff(1)%,%ur.kpss(type="mu")
summary(t2)
x%,%diff(12)%,%diff(1)%,%ggAcf()+theme_bw()
x%,%diff(12)%,%diff(1)%,%ggPacf()+theme_bw()
qQ=list()
for(i in 1:14) qQ[[i]]=c(i-1,0)
qQ[[15]]=c(0,1)
qQ[[16]]=c(1,1)
pP=qQ
 
dt_params=c()
for(i in 1:16){
    for(j in 1:16){
        temp=c(pP[[i]][1],1,qQ[[j]][1],pP[[i]][2],1,qQ[[j]][2],12)
        dt_params=rbind(temp,dt_params)
    }
}
colnames(dt_params)=c("p","d","q","P","D","Q","T")
rownames(dt_params)=1:256
models=vector("list",256)
for(i in 1:256){
  try(models[[i]]<-Arima(x,order = dt_params[i,1:3],
                          seasonal = list(order=dt_params[i,4:6],period=12),
                          lambda = NULL))
}
library(caschrono)
aa=rep(NA,256)
for(i in 1:256){
    if(length(models[[i]]$residuals),1){
        a=Box.test.2(x = models[[i]]$residuals,nlag = 10,type = "Box-Pierce")
        z=prod(1-(a[,2]<.05))
        if(z==1) aa[i]="y"
        else aa[i]="n"
    }
}
dt_params2=data.frame(dt_params)
dt_params2$residuals=aa
aic=rep(NA,256)
model_names=rep(NA,256)
for(i in 1:256){
    if(length(models[[i]]$aic),0){
        aic[i]=models[[i]]$aic
        model_names[i]=as.character(models[[i]])
    }
}
dt_params2$aic=aic
dt_params2$model=model_names
library(DT)
dt_params2$aic=round(dt_params2$aic,4)
dt_params2=na.omit(dt_params2)
datatable(dt_params2,rownames = F)
i=as.numeric(rownames(dt_params2)[which(dt_params2$aic<260)])
res=sapply(i, function(x)as.character(models[[x]]))
res
x_test=sapply(i, function(x)t_stat(models[[x]]))
bb=rep(NA,16)
for(j in 1:16){
    temp=t(x_test[[j]])[,2]
    z=prod((temp<.05))
    bb[j]=z
}
bb
as.character(models[[i[length(i)-1]]])
x_tr <- window(x,end=2009) 
fit <- Arima(x_tr,order = c(3,1,1),
              seasonal = list(order=c(0,1,1),period=12),
              lambda = NULL)
f_fit<-forecast(fit)
autoplot(x_tr, series="Data") + 
    autolayer(fit$fitted, series="SARIMA(3,1,1)(0,1,1)[12]") +
    autolayer(f_fit, series="Prediction") +
    xlab("Year") + ylab("Departures") + ggtitle("Permanent Departures") + theme_bw()+theme(legend.title = element_blank(),legend.position = "bottom")
